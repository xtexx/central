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
    preg_free_if.user free_list_free

    // output logic flush_pipeline,
    // ftq_addr_if.tx ftq_redir
);

  initial assert (free_list_free.BATCH_SIZE >= inst_pkg::ROB_ENTRY_REGS);

  inst_pkg::phy_reg_t reg_aliases[VREGS];

  typedef enum logic [2:0] {FSMIdle} fsm_state_t;

  fsm_state_t state;

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

    // Push registers to free list
    free_list_free.valid = '0;
    for (int i = 0; i < inst_pkg::ROB_ENTRY_REGS; i++) begin
      free_list_free.preg[i]  = rob_rr_old_preg[i];
      free_list_free.valid[i] = (rob_rr_old_preg[i] != 0) && (state == FSMIdle && rob_co.valid);
    end
  end

  always_ff @(posedge clk) begin
    if (!rst) begin
      state <= FSMIdle;
      for (int i = 0; i < VREGS; i++) begin
        reg_aliases[i] <= ($bits(inst_pkg::phy_reg_t))'(i);
      end
    end else begin
      // Idle: Pull ROB entry
      if (state == FSMIdle && rob_co.valid) begin
`ifndef SYNTHESIS
        assert (rob_co.entry.ready);
`endif

        // Update RAT
        for (int i = 0; i < inst_pkg::ROB_ENTRY_REGS; i++) begin
          reg_aliases[rob_rr_vreg[i]] <= rob_rr_new_preg[i];
        end

        // Perform deferred operations
        unique case (rob_co.entry.commit_type)
          InstCommitNop: ;
          InstCommitBranch: ;
          InstCommitException: ;
          InstCommitPhyMem: ;
        endcase
      end
    end
  end

endmodule
