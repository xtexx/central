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
    prf_write_if.user preg_wr,
    preg_free_if.user free_list_free,

    btq_addr_if.rx btq_pop,
    ftq_addr_if.tx ftq_redir,
    output logic flush_pipeline,
    input logic idu_out_valid,
    input logic rr_idle,
    rat_sync_if.tx rat_sync,

    lsq_if.rx lsq_pop,
    taxi_axil_if.rd_mst pmem_rd,
    taxi_axil_if.wr_mst pmem_wr
);

  initial assert (free_list_free.BATCH_SIZE >= inst_pkg::ROB_ENTRY_REGS);
  `ASSERT_STABLE(InstStable, rob_co.valid, rob_co.ready, rob_co.entry, '0, clk, rst);
  `ASSERT_STABLE(BTQStable, btq_pop.valid, btq_pop.ready, btq_pop.hi32, '0, clk, rst);
  `ASSERT_STABLE(LSQStable, lsq_pop.valid, lsq_pop.ready, lsq_pop.entry, '0, clk, rst);

  inst_pkg::phy_reg_t reg_aliases[VREGS];

  typedef enum logic [2:0] {
    FSMIdle,
    FSMBranchPrep,
    FSMBranchRedir,
    FSMMemReq,
    FSMMemRsp
  } fsm_state_t;

  fsm_state_t state;
  logic can_retire;
  logic [31:0] branch_target_hi32, branch_target_lo32;
  logic [1:0] mem_st_req_progress_q, mem_st_req_progress_d;
  logic [63:0] load_result;
  logic mem_retire;

  // Extract RR wires
  inst_pkg::virt_reg_t rob_rr_vreg[inst_pkg::ROB_ENTRY_REGS];
  inst_pkg::phy_reg_t rob_rr_new_preg[inst_pkg::ROB_ENTRY_REGS];
  inst_pkg::phy_reg_t rob_rr_old_preg[inst_pkg::ROB_ENTRY_REGS];

  for (genvar i = 0; i < inst_pkg::ROB_ENTRY_REGS; i++) begin : gen_rob_rr_wires
    assign rob_rr_vreg[i] = rob_co.entry.rr[i].vreg;
    assign rob_rr_new_preg[i] = rob_co.entry.rr[i].new_preg;
    assign rob_rr_old_preg[i] = reg_aliases[rob_rr_vreg[i]];
  end

  `ASSERT_IF(BranchPrepBTQValid, btq_pop.valid, state == FSMBranchPrep, clk, rst);
  `ASSERT_IF(MemReqLSQValid, lsq_pop.valid, state == FSMMemReq, clk, rst);
  `ASSERT_IF(MemRspLSQValid, lsq_pop.valid, state == FSMMemRsp, clk, rst);

  always_comb begin
    preg_wr.preg = '0;
    preg_wr.data = '0;
    preg_wr.valid = '0;

    // Idle, MemRsp, BranchRedir: Pull ROB entry
    can_retire = (state == FSMIdle && (rob_co.entry.commit_type != InstCommitMem || mem_retire));
    rob_co.ready = can_retire || (state == FSMBranchRedir);

    // Idle: Push registers to free list
    // BranchRedir: Restore PReg free list
    free_list_free.valid = '0;
    for (int i = 0; i < inst_pkg::ROB_ENTRY_REGS; i++) begin
      free_list_free.preg[i] = 0;
      unique case (state)
        FSMBranchRedir: free_list_free.preg[i] = rob_rr_new_preg[i];
        default: free_list_free.preg[i] = rob_rr_old_preg[i];
      endcase
      free_list_free.valid[i] = (free_list_free.preg[i] != 0) && rob_co.valid && rob_co.ready;
    end

    // BranchPrep: Pop high 32 bit of target address from BTQ
    btq_pop.ready = (state == FSMBranchPrep);

    // BranchRedir: Update FTQ; flush pipeline; sync RAT
    ftq_redir.addr = (ftq_redir.ADDR_W)'({branch_target_hi32, branch_target_lo32});
    ftq_redir.valid = (state == FSMBranchRedir);
    flush_pipeline = (state == FSMBranchRedir);
    rat_sync.pregs = reg_aliases;
    rat_sync.valid = (state == FSMBranchRedir);

    // MemReq: Send AR for load, send AW/W for store
    pmem_rd.araddr = lsq_pop.entry.addr[pmem_rd.ADDR_W-1:0];
    pmem_rd.arprot = '0;
    pmem_rd.aruser = '0;
    pmem_rd.arvalid = (state == FSMMemReq && !lsq_pop.entry.is_store);

    pmem_wr.awaddr = lsq_pop.entry.addr[pmem_wr.ADDR_W-1:0];
    pmem_wr.awprot = '0;
    pmem_wr.awuser = '0;
    pmem_wr.awvalid = (state == FSMMemReq && lsq_pop.entry.is_store);

    pmem_wr.wdata = lsq_pop.entry.u.st.data;
    pmem_wr.wstrb = lsq_pop.entry.strb;
    pmem_wr.wuser = '0;
    pmem_wr.wvalid = (state == FSMMemReq && lsq_pop.entry.is_store);

    mem_st_req_progress_d = mem_st_req_progress_q;
    mem_st_req_progress_d[0] |= pmem_wr.awvalid && pmem_wr.awready;
    mem_st_req_progress_d[1] |= pmem_wr.wvalid && pmem_wr.wready;

    // MemRsp: Receive R for load, receive B for store
    pmem_rd.rready = (state == FSMMemRsp && !lsq_pop.entry.is_store);
    pmem_wr.bready = (state == FSMMemRsp && lsq_pop.entry.is_store);

    // MemRsp: Write load result
    load_result = pmem_rd.rdata;
    for (int i = 0; i < 8; i++) begin
      load_result[i*8+:8] = load_result[i*8+:8] & {8{lsq_pop.entry.strb[i]}};
    end
    load_result = load_result >> (lsq_pop.entry.u.ld.shr * 8);
    unique case (lsq_pop.entry.u.ld.ext)
      0: load_result = 64'(signed'(load_result[7:0]));
      1: load_result = 64'(signed'(load_result[15:0]));
      2: load_result = 64'(signed'(load_result[31:0]));
      3: ;
    endcase
    if (state == FSMMemRsp && !lsq_pop.entry.is_store) begin
      preg_wr.preg  = lsq_pop.entry.u.ld.dst;
      preg_wr.data  = load_result;
      preg_wr.valid = '1;
    end

    // MemRsp: Pop LSQ entry
    lsq_pop.ready = mem_retire;
  end

  always_ff @(posedge clk) begin
    mem_retire <= '0;
    if (rst) begin
      state <= FSMIdle;
      for (int i = 0; i < VREGS; i++) begin
        reg_aliases[i] <= ($bits(inst_pkg::phy_reg_t))'(i);
      end
      mem_st_req_progress_q <= '0;
    end else begin
      // Update RAT when retiring ROB entry
      if (rob_co.valid && can_retire) begin
        for (int i = 0; i < inst_pkg::ROB_ENTRY_REGS; i++) begin
          reg_aliases[rob_rr_vreg[i]] <= rob_rr_new_preg[i];
        end
      end
      // Idle: Pull ROB entry
      if (state == FSMIdle && rob_co.valid) begin
        `ASSERT_I(ROBEntryIsReady, rob_co.entry.ready);

        // Perform deferred operations
        unique case (rob_co.entry.commit_type)
          InstCommitNop: ;
          InstCommitBranch: begin
            branch_target_lo32 <= rob_co.entry.commit_data;
            state <= FSMBranchPrep;
          end
          InstCommitException: ;
          InstCommitMem: if (!mem_retire) state <= FSMMemReq;
        endcase
      end
      // BranchPrep: Save high 32 bit of address
      if (state == FSMBranchPrep) begin
        branch_target_hi32 <= btq_pop.hi32;
        state <= FSMBranchRedir;
      end
      // BranchRedir: Wait for ROB to be cleared; wait for IFU and RR to reset
      if (state == FSMBranchRedir && ftq_redir.ready && !rob_co.valid && !idu_out_valid && rr_idle) begin
        state <= FSMIdle;
      end
      // MemReq: Complete AR/AW/W handshake
      if (state == FSMMemReq) begin
        if (pmem_rd.arvalid && pmem_rd.arready) state <= FSMMemRsp;
        if (mem_st_req_progress_d == 2'b11) begin
          mem_st_req_progress_q <= 0;
          state <= FSMMemRsp;
        end else mem_st_req_progress_q <= mem_st_req_progress_d;
      end
      // MemRsp: Complete R/B handshake
      if (state == FSMMemRsp &&
        ((pmem_wr.bvalid && pmem_wr.bready) || (pmem_rd.rvalid && pmem_rd.rready))) begin
        // TODO: check bresp and rresp
        mem_retire <= 1;
        state <= FSMIdle;
      end
    end
  end

endmodule
