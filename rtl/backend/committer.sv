`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

module committer
  import inst_pkg::*;
#(
    parameter int unsigned VREGS = 32
) (
    input logic clk,
    input logic rst,
    rob_commit_if.committer rob_co,
    preg_free_if.user free_list_free,

    btq_addr_if.rx btq_pop,
    ftq_addr_if.tx ftq_redir,
    output logic flush_pipeline,
    input logic idu_out_valid,
    rat_sync_if.tx rat_sync
);

  initial assert (free_list_free.BATCH_SIZE >= inst_pkg::ROB_ENTRY_REGS);

  inst_pkg::phy_reg_t reg_aliases[VREGS];

  typedef enum logic [2:0] {
    FSMIdle,
    FSMBranchPrep,
    FSMBranchRedir
  } fsm_state_t;

  fsm_state_t state;

  logic [31:0] branch_target_hi32, branch_target_lo32;

  // Extract RR wires
  inst_pkg::virt_reg_t rob_rr_vreg[inst_pkg::ROB_ENTRY_REGS];
  inst_pkg::phy_reg_t rob_rr_new_preg[inst_pkg::ROB_ENTRY_REGS];
  inst_pkg::phy_reg_t rob_rr_old_preg[inst_pkg::ROB_ENTRY_REGS];

  for (genvar i = 0; i < inst_pkg::ROB_ENTRY_REGS; i++) begin : gen_rob_rr_wires
    assign rob_rr_vreg[i] = rob_co.entry.rr[i].vreg;
    assign rob_rr_new_preg[i] = rob_co.entry.rr[i].new_preg;
    assign rob_rr_old_preg[i] = reg_aliases[rob_rr_vreg[i]];
  end

  always_comb begin
    // Idle: Pull ROB entry
    rob_co.ready = (state == FSMIdle);

    // Idle: Push registers to free list
    // BranchRedir: Restore PReg free list
    free_list_free.valid = '0;
    for (int i = 0; i < inst_pkg::ROB_ENTRY_REGS; i++) begin
      free_list_free.preg[i] = 0;
      unique case (state)
        FSMBranchRedir: free_list_free.preg[i] = rob_rr_new_preg[i];
        default: free_list_free.preg[i] = rob_rr_old_preg[i];
      endcase
      free_list_free.valid[i] = (free_list_free.preg[i] != 0) && rob_co.valid;
    end

    // BranchPrep: Pop high 32 bit of target address from BTQ
    `ASSERT_I(BranchPrepBTQIsNotEmpty, (state != FSMBranchPrep) || btq_pop.valid);
    btq_pop.ready   = (state == FSMBranchPrep);

    // BranchRedir: Update FTQ; flush pipeline; sync RAT
    ftq_redir.addr  = (ftq_redir.ADDR_W)'({branch_target_hi32, branch_target_lo32});
    ftq_redir.valid = (state == FSMBranchRedir);
    flush_pipeline  = (state == FSMBranchRedir);
    rat_sync.pregs  = reg_aliases;
    rat_sync.valid  = (state == FSMBranchRedir);
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      state <= FSMIdle;
      for (int i = 0; i < VREGS; i++) begin
        reg_aliases[i] <= ($bits(inst_pkg::phy_reg_t))'(i);
      end
    end else begin
      // Idle: Pull ROB entry
      if (state == FSMIdle && rob_co.valid) begin
        `ASSERT_I(ROBEntryIsReady, rob_co.entry.ready);

        // Update RAT
        for (int i = 0; i < inst_pkg::ROB_ENTRY_REGS; i++) begin
          reg_aliases[rob_rr_vreg[i]] <= rob_rr_new_preg[i];
        end

        // Perform deferred operations
        unique case (rob_co.entry.commit_type)
          InstCommitNop: ;
          InstCommitBranch: begin
            branch_target_lo32 <= rob_co.entry.commit_data;
            state <= FSMBranchPrep;
          end
          InstCommitException: ;
          InstCommitPhyMem: ;
        endcase
      end
      // BranchPrep: Save high 32 bit of address
      if (state == FSMBranchPrep) begin
        branch_target_hi32 <= btq_pop.hi32;
        state <= FSMBranchRedir;
      end
      // BranchRedir: Wait for ROB to be cleared
      if (state == FSMBranchRedir && ftq_redir.ready && !rob_co.valid && !idu_out_valid) begin
        state <= FSMIdle;
      end
    end
  end

endmodule
