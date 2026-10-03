`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"
`include "../macros/errors.svh"

// ALU Execute Unit
module alu_exec
  import inst_pkg::*;
(
    input logic clk,
    input logic rst,
    rr_out_if.rx in,
    prf_read_if.user prf_rd[2],
    prf_write_if.user prf_wr,
    rob_execute_if.exec rob_ex
);

  `ASSERT_STABLE(ALUInStable, in.valid, in.ready, in.inst, '0, clk, rst);

  logic is_bin_op, ready;
  logic [63:0] rd, rj, rk;

  inst_pkg::uop_add_pl_t uop_add_pl;
  inst_pkg::uop_bitop_imm_pl_t uop_bitop_imm_pl;

  always_comb begin
    // Payload decode
    uop_add_pl = in.inst.pl[$bits(inst_pkg::uop_add_pl_t)-1:0];
    uop_bitop_imm_pl = in.inst.pl[$bits(inst_pkg::uop_bitop_imm_pl_t)-1:0];

    // Classify binary operators
    is_bin_op = 0;
    unique case (in.inst.op)
      UOpAdd: is_bin_op = 1;
      UOpAddImm, UOpBitOpImm: is_bin_op = 0;
      default: if (!rst) `ERROR("ALU Exec: bad op");
    endcase

    // Read operand registers
    prf_rd[0].preg = in.inst.pregs_r[0];
    prf_rd[1].preg = in.inst.pregs_r[1];
    rj = prf_rd[0].data;
    rk = prf_rd[1].data;

    // Wait for operand
    ready = !rst && in.valid && prf_rd[0].ready && (prf_rd[1].ready || !is_bin_op);

    // Perform calculation
    rd = '0;
    unique case (in.inst.op)
      UOpAdd, UOpAddImm: begin
        // rd = RHS
        rd = (in.inst.op == UOpAddImm) ? unsigned'(64'(signed'(uop_add_pl.si12))) : rk;
        // rd = rj +- rd
        rd = (uop_add_pl.is_sub) ? (rj - rd) : (rj + rd);
        // rd = IS_W ? SignExtend(rd[31:0]) : rd
        rd = (uop_add_pl.is_w) ? unsigned'(64'(signed'(rd[31:0]))) : rd;
      end
      UOpBitOpImm: begin
        if (uop_bitop_imm_pl.is_andi) begin
          rd = rj & 64'(uop_bitop_imm_pl.ui12);
        end else if (uop_bitop_imm_pl.is_ori) begin
          rd = rj | 64'(uop_bitop_imm_pl.ui12);
        end else if (uop_bitop_imm_pl.is_xori) begin
          rd = rj ^ 64'(uop_bitop_imm_pl.ui12);
        end else if (ready) `ERROR("ALU Exec: UOpBitOpImm nop");
      end
      default: if (ready) `ERROR("ALU Exec: bad op");
    endcase

    // Write to destination register
    prf_wr.preg = in.inst.pregs_w[0];
    prf_wr.data = rd;
    prf_wr.valid = ready;

    // Pop instruction from DQ
    in.ready = ready;

    // ROB write back
    rob_ex.idx = in.inst.rob_idx;
    rob_ex.commit_type = InstCommitNop;
    rob_ex.data = '0;
    rob_ex.valid = ready;
  end

endmodule
