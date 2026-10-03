`timescale 1ns / 1ps
`default_nettype wire

// Register Renames
// Updates RAT and allocates ROB entry
module register_renamer #(
    parameter int unsigned VREGS = 32
) (
    input wire clk,
    input wire rst,
    inst_dec_out_if.rx idu_if,
    preg_alloc_if.user free_list_if,
    prf_reset_if.user prf_rst_if[2],
    rob_alloc_if.requester rob_if,
    rr_out_if.tx out_if
);

  import ifu_pkg::*;

  inst_pkg::virt_reg_t vreg_r0;
  assign vreg_r0.idx = 0;

  inst_pkg::phy_reg_t reg_aliases[VREGS];

  typedef enum logic [2:0] {
    RRFSMFetchInst,
    RRFSMOutput,
    RRFSMAllocPReg,
    RRFSMROBAlloc
  } fsm_state_t;

  fsm_state_t state;
  inst_pkg::rr_inst_t rr_inst;
  inst_pkg::rob_idx_t rob_idx;

  inst_pkg::phy_reg_t pregs_r[2];
  inst_pkg::phy_reg_t pregs_w[2];

  inst_pkg::inst_opcode_t op;
  inst_pkg::inst_payload_t pl;
  inst_pkg::virt_reg_t [1:0] vregs_w;
  logic [63:0] pc;

  always_comb begin
    // Pull instruction from IDU
    idu_if.ready = (state == RRFSMFetchInst);

    // Wire instruction opcode and payload
    rr_inst.op = op;
    rr_inst.pl = pl;
    rr_inst.pregs_r[0] = pregs_r[0];
    rr_inst.pregs_r[1] = pregs_r[1];
    rr_inst.pregs_w[0] = pregs_w[0];
    rr_inst.pregs_w[1] = pregs_w[1];
    rr_inst.rob_idx = rob_idx;

    // Push RR instruction
    out_if.valid = (state == RRFSMOutput);
    out_if.inst = rr_inst;

    // Request ROB allocation
    rob_if.valid = (state == RRFSMROBAlloc);
    rob_if.pc = pc;
    rob_if.rr[0].vreg = vregs_w[0];
    rob_if.rr[0].new_preg = pregs_w[0];
    rob_if.rr[1].vreg = vregs_w[1];
    rob_if.rr[1].new_preg = pregs_w[1];

    // Reset physical register ready bit
    prf_rst_if[0].preg = pregs_w[0];
    prf_rst_if[0].valid = (state == RRFSMROBAlloc && rob_if.ready);
    prf_rst_if[1].preg = pregs_w[1];
    prf_rst_if[1].valid = (state == RRFSMROBAlloc && rob_if.ready);
  end

  inst_pkg::phy_reg_t pregs_w_d[2];
  logic [free_list_if.NUM_W-1:0] free_list_needed;
  logic [free_list_if.NUM_W-1:0] free_list_used;

  always_comb begin
    free_list_needed = 0;
    free_list_used = 0;
    pregs_w_d[0] = 0;
    pregs_w_d[1] = 0;
    for (int i = 0; i < 2; i++) begin
      if (vregs_w[i] != vreg_r0) begin
        free_list_needed = free_list_needed + 1;
        if (free_list_if.valid[free_list_if.IDX_W'(free_list_used)]) begin
          pregs_w_d[i]   = free_list_if.preg[free_list_if.IDX_W'(free_list_used)];
          free_list_used = free_list_used + 1;
        end
      end
    end

    free_list_if.used = 0;
    if (state == RRFSMAllocPReg && free_list_used == free_list_needed) begin
      free_list_if.used = free_list_used;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      state <= RRFSMFetchInst;
      for (int i = 0; i < VREGS; i++) begin
        reg_aliases[i] <= ($bits(inst_pkg::phy_reg_t))'(i);
      end
    end else begin
      // Receive instruction from IDU
      if (state == RRFSMFetchInst && idu_if.valid) begin
        op <= idu_if.inst.op;
        pl <= idu_if.inst.pl;
        pc <= idu_if.inst.pc;
        vregs_w[0] <= idu_if.inst.vregs_w[0];
        vregs_w[1] <= idu_if.inst.vregs_w[1];
        pregs_r[0] <= reg_aliases[idu_if.inst.vregs_r[0]];
        pregs_r[1] <= reg_aliases[idu_if.inst.vregs_r[1]];
        if (idu_if.inst.vregs_w[0] == vreg_r0 && idu_if.inst.vregs_w[1] == vreg_r0) begin
          pregs_w[0] <= 0;
          pregs_w[1] <= 0;
          state <= RRFSMROBAlloc;
        end else begin
          state <= RRFSMAllocPReg;
        end
      end
      // Physical register allocation
      if (state == RRFSMAllocPReg && free_list_used == free_list_needed) begin
        pregs_w <= pregs_w_d;
        reg_aliases[vregs_w[0]] <= pregs_w_d[0];
        reg_aliases[vregs_w[1]] <= pregs_w_d[1];
        state <= RRFSMROBAlloc;
      end
      // ROB allocation handshake
      if (state == RRFSMROBAlloc && rob_if.ready) begin
        rob_idx <= rob_if.idx;
        state   <= RRFSMOutput;
      end
      // Output handshake
      if (state == RRFSMOutput && out_if.ready) begin
        state <= RRFSMFetchInst;
      end
    end
  end

endmodule
