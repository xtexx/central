`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

`define LA_DEC(__op, __pl) \
  out.inst.op = (UOp``__op); \
  out.inst.pl = 32'(unsigned'(__pl)); \

`define LA_DEC_REG_R_GPR(__slot, __r) \
  out.inst.vregs_r[__slot].idx = (__r);

`define LA_DEC_REG_W_GPR(__slot, __r) \
  out.inst.vregs_w[__slot].idx = (__r);

// Decoders

`define LA_DEC_ADD_SUB(__is_sub, __is_w) \
  begin \
    uop_add_pl.is_sub = __is_sub; \
    uop_add_pl.is_w = __is_w; \
    `LA_DEC(Add, uop_add_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
    `LA_DEC_REG_R_GPR(1, op_rk) \
  end

`define LA_DECODE_INST_ADD_W `LA_DEC_ADD_SUB(0, 1)
`define LA_DECODE_INST_ADD_D `LA_DEC_ADD_SUB(0, 0)
`define LA_DECODE_INST_SUB_W `LA_DEC_ADD_SUB(1, 1)
`define LA_DECODE_INST_SUB_D `LA_DEC_ADD_SUB(1, 0)

`define LA_DEC_ADD_SUB_IMM(__is_sub, __is_w) \
  begin \
    uop_add_pl.is_sub = __is_sub; \
    uop_add_pl.is_w = __is_w; \
    uop_add_pl.si12 = op_sk12; \
    `LA_DEC(AddImm, uop_add_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
  end

`define LA_DECODE_INST_ADDI_W `LA_DEC_ADD_SUB_IMM(0, 1)
`define LA_DECODE_INST_ADDI_D `LA_DEC_ADD_SUB_IMM(0, 0)
`define LA_DECODE_INST_SUBI_W `LA_DEC_ADD_SUB_IMM(1, 1)
`define LA_DECODE_INST_SUBI_D `LA_DEC_ADD_SUB_IMM(1, 0)

`define LA_DEC_BITOP_IMM12(__op) \
  begin \
    uop_bitop_imm_pl.is_``__op = '1; \
    uop_bitop_imm_pl.ui12 = op_uk12; \
    `LA_DEC(BitOpImm, uop_bitop_imm_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
  end

`define LA_DECODE_INST_ANDI `LA_DEC_BITOP_IMM12(andi)
`define LA_DECODE_INST_ORI `LA_DEC_BITOP_IMM12(ori)
`define LA_DECODE_INST_XORI `LA_DEC_BITOP_IMM12(xori)

`define LA_DECODE_INST_LU12I_W begin \
    uop_ld_imm_pl.imm = op_sj20; \
    `LA_DEC(LdImm, uop_ld_imm_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
  end

`define LA_DECODE_INST_CU32I_D begin \
    uop_ld_imm_pl.imm = op_sj20; \
    uop_ld_imm_pl.is_lu32id = 1; \
    `LA_DEC(LdImm, uop_ld_imm_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rd) \
  end

`define LA_DECODE_INST_CU52I_D begin \
    uop_ld_imm_pl.imm = 20'(op_uk12); \
    `LA_DEC(LdImm, uop_ld_imm_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
  end

`define LA_DECODE_INST_BREAK begin \
    `LA_DEC(Exception, 'h0C) \
  end

`define LA_DECODE_INST_B begin \
    uop_br_pl.offs26 = op_offs26; \
    uop_br_pl.base_reg = 0; \
    `LA_DEC(Br, uop_br_pl) \
    `LA_DEC_REG_W_GPR(0, 0) \
  end

`define LA_DECODE_INST_BL begin \
    uop_br_pl.offs26 = op_offs26; \
    uop_br_pl.base_reg = 0; \
    `LA_DEC(Br, uop_br_pl) \
    `LA_DEC_REG_W_GPR(0, 1) \
  end

`define LA_DECODE_INST_JIRL begin \
    uop_br_pl.offs26 = 26'(signed'(op_offs16)); \
    uop_br_pl.base_reg = 1; \
    `LA_DEC(Br, uop_br_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
  end

`define LA_DEC_MEM_LD(__rk, __offs, __ty, __is_unsigned) \
  begin \
    uop_mem_pl.is_store = '0; \
    uop_mem_pl.offs = 16'(__offs); \
    uop_mem_pl.ty = MemOpType``__ty; \
    uop_mem_pl.is_unsigned = __is_unsigned; \
    `LA_DEC(Mem, uop_mem_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
    `LA_DEC_REG_R_GPR(1, __rk) \
  end

`define LA_DEC_MEM_ST(__rk, __offs, __ty) \
  begin \
    uop_mem_pl.is_store = '1; \
    uop_mem_pl.offs = 16'(__offs); \
    uop_mem_pl.ty = MemOpType``__ty; \
    uop_mem_pl.is_unsigned = '0; \
    `LA_DEC(Mem, uop_mem_pl) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
    `LA_DEC_REG_R_GPR(1, __rk) \
    `LA_DEC_REG_R_GPR(2, op_rd) \
  end

`define LA_DECODE_INST_LD_B `LA_DEC_MEM_LD(0, signed'(op_sk12), B, '0)
`define LA_DECODE_INST_LD_BU `LA_DEC_MEM_LD(0, signed'(op_sk12), B, '1)
`define LA_DECODE_INST_LD_H `LA_DEC_MEM_LD(0, signed'(op_sk12), H, '0)
`define LA_DECODE_INST_LD_HU `LA_DEC_MEM_LD(0, signed'(op_sk12), H, '1)
`define LA_DECODE_INST_LD_W `LA_DEC_MEM_LD(0, signed'(op_sk12), W, '0)
`define LA_DECODE_INST_LD_WU `LA_DEC_MEM_LD(0, signed'(op_sk12), W, '1)
`define LA_DECODE_INST_LD_D `LA_DEC_MEM_LD(0, signed'(op_sk12), D, '0)

`define LA_DECODE_INST_ST_B `LA_DEC_MEM_ST(0, signed'(op_sk12), B)
`define LA_DECODE_INST_ST_H `LA_DEC_MEM_ST(0, signed'(op_sk12), H)
`define LA_DECODE_INST_ST_W `LA_DEC_MEM_ST(0, signed'(op_sk12), W)
`define LA_DECODE_INST_ST_D `LA_DEC_MEM_ST(0, signed'(op_sk12), D)

`define LA_DECODE_INST_LDX_B `LA_DEC_MEM_LD(op_rk, 0, B, '0)
`define LA_DECODE_INST_LDX_BU `LA_DEC_MEM_LD(op_rk, 0, B, '1)
`define LA_DECODE_INST_LDX_H `LA_DEC_MEM_LD(op_rk, 0, H, '0)
`define LA_DECODE_INST_LDX_HU `LA_DEC_MEM_LD(op_rk, 0, H, '1)
`define LA_DECODE_INST_LDX_W `LA_DEC_MEM_LD(op_rk, 0, W, '0)
`define LA_DECODE_INST_LDX_WU `LA_DEC_MEM_LD(op_rk, 0, W, '1)
`define LA_DECODE_INST_LDX_D `LA_DEC_MEM_LD(op_rk, 0, D, '0)

`define LA_DECODE_INST_STX_B `LA_DEC_MEM_ST(op_rk, 0, B)
`define LA_DECODE_INST_STX_H `LA_DEC_MEM_ST(op_rk, 0, H)
`define LA_DECODE_INST_STX_W `LA_DEC_MEM_ST(op_rk, 0, W)
`define LA_DECODE_INST_STX_D `LA_DEC_MEM_ST(op_rk, 0, D)

`define LA_DECODE_INST_LDOX4_W `LA_DEC_MEM_LD(0, signed'({op_sk14, 2'b0}), W, '0)
`define LA_DECODE_INST_LDOX4_D `LA_DEC_MEM_LD(0, signed'({op_sk14, 2'b0}), D, '0)

`define LA_DECODE_INST_STOX4_W `LA_DEC_MEM_ST(0, signed'({op_sk14, 2'b0}), W)
`define LA_DECODE_INST_STOX4_D `LA_DEC_MEM_ST(0, signed'({op_sk14, 2'b0}), D)

`define LA_DECODE_INST_PRELD is_nop = 1;
`define LA_DECODE_INST_PRELDX is_nop = 1;

`define LA_DECODE_INST_CACOP is_nop = 1;

`include "../gen/decode_tree.svh"

// Instruction Decoder Unit
module inst_decoder
  import ifu_pkg::*;
  import inst_pkg::*;
(
    input logic rst,
    ifu_out_if.rx in,
    inst_dec_out_if.tx out
);

  logic invalid_inst, is_nop;

  virt_reg_t op_rd, op_rj, op_rk;
  logic unsigned [11:0] op_uk12;
  logic signed   [11:0] op_sk12;
  logic signed   [13:0] op_sk14;
  logic signed   [19:0] op_sj20;
  logic signed   [25:0] op_offs26;
  logic signed   [15:0] op_offs16;

  always_comb begin
    op_rd = in.inst[4:0];
    op_rj = in.inst[9:5];
    op_rk = in.inst[14:10];

    op_uk12 = in.inst[21:10];
    op_sk12 = signed'(op_uk12);
    op_sk14 = signed'(in.inst[23:10]);
    op_sj20 = signed'(in.inst[24:5]);

    op_offs26 = signed'({in.inst[9:0], in.inst[25:10]});
    op_offs16 = signed'(in.inst[25:10]);
  end

  inst_pkg::uop_add_pl_t uop_add_pl;
  inst_pkg::uop_bitop_imm_pl_t uop_bitop_imm_pl;
  inst_pkg::uop_ld_imm_pl_t uop_ld_imm_pl;
  inst_pkg::uop_br_pl_t uop_br_pl;
  inst_pkg::uop_mem_pl_t uop_mem_pl;

  always_comb begin
    // Default assignments
    out.inst.op = inst_pkg::inst_opcode_t'(0);
    out.inst.pl = '0;
    out.inst.vregs_r = '0;
    out.inst.vregs_w = '0;

    is_nop = 0;
    invalid_inst = 0;

    uop_add_pl = '0;
    uop_bitop_imm_pl = '0;
    uop_ld_imm_pl = '0;
    uop_br_pl = '0;
    uop_mem_pl = '0;

    // Decoder tree
    `LA_DECODE_TREE

    // Identify NOP instructions
    is_nop |= (in.inst == 32'h03400000);

    // Catch invalid instructions
    if (invalid_inst == 1) begin
      out.inst.op = UOpException;
      out.inst.pl[5:0] = 'h0D;  // INE exception
    end

    // Handshake passthrough
    out.valid = in.valid && !is_nop;
    in.ready = out.ready || is_nop;
    out.inst.pc = 64'(in.pc);
  end

endmodule
