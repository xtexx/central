`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

`define LA_DEC(__op, __pl) \
  out.inst.op = (UOp``__op); \
  out.inst.pl = 32'(unsigned'(__pl)); \

`define LA_DEC_REG_R(__slot, __r) \
  out.inst.vregs_r[__slot] = (__r);

`define LA_DEC_REG_W(__slot, __r) \
  out.inst.vregs_w[__slot] = (__r);

`define LA_DEC_ADD_SUB_DJK(__is_sub, __is_w) \
  begin \
    uop_add_pl.is_sub = __is_sub; \
    uop_add_pl.is_w = __is_w; \
    `LA_DEC(Add, uop_add_pl) \
    `LA_DEC_REG_R(0, op_rj) \
    `LA_DEC_REG_R(1, op_rk) \
    `LA_DEC_REG_W(0, op_rd) \
  end

// Decoders

`define LA_DECODE_INST_ADD_W `LA_DEC_ADD_SUB_DJK(0, 1)
`define LA_DECODE_INST_ADD_D `LA_DEC_ADD_SUB_DJK(0, 0)
`define LA_DECODE_INST_SUB_W `LA_DEC_ADD_SUB_DJK(1, 1)
`define LA_DECODE_INST_SUB_D `LA_DEC_ADD_SUB_DJK(1, 0)

`define LA_DECODE_INST_BREAK begin \
    `LA_DEC(Exception, 'h0C) \
  end

`include "../gen/decode_tree.svh"

// Instruction Decoder & Register Rename & Dispatcher Unit
module inst_decoder
  import ifu_pkg::*;
  import inst_pkg::*;
(
    input wire clk,
    input wire rst,
    ifu_out_if.rx in,
    inst_dec_out_if.tx out
);

  logic invalid_inst;

  virt_reg_t op_rd, op_rj, op_rk;

  always_comb begin
    op_rd = in.inst[4:0];
    op_rj = in.inst[9:5];
    op_rk = in.inst[14:10];
  end

  inst_pkg::uop_add_pl_t uop_add_pl;

  always_comb begin
    // Handshake passthrough
    out.valid = in.valid;
    in.ready = out.ready;
    out.inst.pc = 64'(in.pc);

    // Default assignments
    out.inst.op = inst_pkg::inst_opcode_t'(0);
    out.inst.pl = '0;
    out.inst.vregs_r = '0;
    out.inst.vregs_w = '0;

    invalid_inst = 0;

    uop_add_pl = '0;

    // Decoder tree
    `LA_DECODE_TREE

    // Catch invalid instructions
    if (invalid_inst == 1) begin
      out.inst.op = UOpException;
      out.inst.pl[5:0] = 'h0D;  // INE exception
    end
  end

endmodule
