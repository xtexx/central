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

`define LA_DECODE_INST_ADDU16I_D \
  begin \
    uop_bitop_pl.ty = BitOpTyAddu16id; \
    uop_bitop_pl.ui16 = unsigned'(op_sk16); \
    `LA_DEC(BitOp, uop_bitop_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
  end

`define LA_DEC_BITOP_IMM12(__op) \
  begin \
    uop_bitop_pl.ty = BitOpTy``__op``Imm; \
    uop_bitop_pl.ui16 = 16'(unsigned'(op_uk12)); \
    `LA_DEC(BitOp, uop_bitop_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
  end

`define LA_DECODE_INST_ANDI `LA_DEC_BITOP_IMM12(And)
`define LA_DECODE_INST_ORI `LA_DEC_BITOP_IMM12(Or)
`define LA_DECODE_INST_XORI `LA_DEC_BITOP_IMM12(Xor)

`define LA_DECODE_INST_SLTI `LA_DEC_BITOP_IMM12(SetLtS)
`define LA_DECODE_INST_SLTUI `LA_DEC_BITOP_IMM12(SetLtU)

`define LA_DEC_BITOP(__op, __rj, __rk) \
  begin \
    uop_bitop_pl.ty = BitOpTy``__op; \
    `LA_DEC(BitOp, uop_bitop_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, __rj) \
    `LA_DEC_REG_R_GPR(1, __rk) \
  end

`define LA_DECODE_INST_AND `LA_DEC_BITOP(And, op_rj, op_rk)
`define LA_DECODE_INST_OR `LA_DEC_BITOP(Or, op_rj, op_rk)
`define LA_DECODE_INST_ANDN `LA_DEC_BITOP(Andn, op_rj, op_rk)
`define LA_DECODE_INST_ORN `LA_DEC_BITOP(Orn, op_rj, op_rk)
`define LA_DECODE_INST_XOR `LA_DEC_BITOP(Xor, op_rj, op_rk)
`define LA_DECODE_INST_NOR `LA_DEC_BITOP(Nor, op_rj, op_rk)

`define LA_DECODE_INST_MASKEQZ `LA_DEC_BITOP(MaskEqz, op_rj, op_rk)
`define LA_DECODE_INST_MASKNEZ `LA_DEC_BITOP(MaskNez, op_rj, op_rk)

`define LA_DECODE_INST_SLT `LA_DEC_BITOP(SetLtS, op_rj, op_rk)
`define LA_DECODE_INST_SLTU `LA_DEC_BITOP(SetLtU, op_rj, op_rk)

`define LA_DECODE_INST_REVBIT_W `LA_DEC_BITOP(BitRevW, op_rj, 0)
`define LA_DECODE_INST_REVBIT_D `LA_DEC_BITOP(BitRevD, op_rj, 0)
`define LA_DECODE_INST_REVBIT_4B `LA_DEC_BITOP(BitRev4B, op_rj, 0)
`define LA_DECODE_INST_REVBIT_8B `LA_DEC_BITOP(BitRev8B, op_rj, 0)

`define LA_DECODE_INST_REVH_2W `LA_DEC_BITOP(RevH2W, op_rj, 0)
`define LA_DECODE_INST_REVH_D `LA_DEC_BITOP(RevHD, op_rj, 0)
`define LA_DECODE_INST_REVB_2H `LA_DEC_BITOP(RevB2H, op_rj, 0)
`define LA_DECODE_INST_REVB_4H `LA_DEC_BITOP(RevB4H, op_rj, 0)
`define LA_DECODE_INST_REVB_2W `LA_DEC_BITOP(RevB2W, op_rj, 0)
`define LA_DECODE_INST_REVB_D `LA_DEC_BITOP(RevBD, op_rj, 0)

`define LA_DECODE_INST_SEXT_B `LA_DEC_BITOP(ExtWB, op_rj, 0)
`define LA_DECODE_INST_SEXT_H `LA_DEC_BITOP(ExtWH, op_rj, 0)

`define LA_DECODE_INST_CLO_W `LA_DEC_BITOP(CLOW, op_rj, 0)
`define LA_DECODE_INST_CLO_D `LA_DEC_BITOP(CLOD, op_rj, 0)
`define LA_DECODE_INST_CLZ_W `LA_DEC_BITOP(CLZW, op_rj, 0)
`define LA_DECODE_INST_CLZ_D `LA_DEC_BITOP(CLZD, op_rj, 0)
`define LA_DECODE_INST_CTO_W `LA_DEC_BITOP(CTOW, op_rj, 0)
`define LA_DECODE_INST_CTO_D `LA_DEC_BITOP(CTOD, op_rj, 0)
`define LA_DECODE_INST_CTZ_W `LA_DEC_BITOP(CTZW, op_rj, 0)
`define LA_DECODE_INST_CTZ_D `LA_DEC_BITOP(CTZD, op_rj, 0)

`define LA_DEC_BITOP_RRRI(__op, __imm) \
  begin \
    uop_bitop_pl.ty = BitOpTy``__op; \
    uop_bitop_pl.ui16 = 16'(unsigned'(__imm)); \
    `LA_DEC(BitOp, uop_bitop_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
    `LA_DEC_REG_R_GPR(1, op_rk) \
  end

`define LA_DECODE_INST_SLADD_W `LA_DEC_BITOP_RRRI(SlAddW, op_sa2)
`define LA_DECODE_INST_SLADD_WU `LA_DEC_BITOP_RRRI(SlAddWU, op_sa2)
`define LA_DECODE_INST_SLADD_D `LA_DEC_BITOP_RRRI(SlAddD, op_sa2)

`define LA_DECODE_INST_CATPICK_W `LA_DEC_BITOP_RRRI(BytePickW, op_sa2)
`define LA_DECODE_INST_CATPICK_D `LA_DEC_BITOP_RRRI(BytePickD, op_sa3)

`define LA_DEC_LD_IMM(__op, __imm20, __rr0) \
  begin \
    uop_ld_imm_pl.imm = __imm20; \
    uop_ld_imm_pl.op = LdImmOp``__op; \
    `LA_DEC(LdImm, uop_ld_imm_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, __rr0) \
  end

`define LA_DECODE_INST_LU12I_W `LA_DEC_LD_IMM(LU12IW, op_sj20, 0)
`define LA_DECODE_INST_CU32I_D `LA_DEC_LD_IMM(CU32ID, op_sj20, op_rd)
`define LA_DECODE_INST_CU52I_D `LA_DEC_LD_IMM(CU52ID, 20'(op_uk12), op_rj)
`define LA_DECODE_INST_PCADDU2I `LA_DEC_LD_IMM(PCADDU2I, op_sj20, 0)
`define LA_DECODE_INST_PCADDU12I `LA_DEC_LD_IMM(PCADDU12I, op_sj20, 0)
`define LA_DECODE_INST_PCADDU18I `LA_DEC_LD_IMM(PCADDU18I, op_sj20, 0)
`define LA_DECODE_INST_PCALAU12I `LA_DEC_LD_IMM(PCALAU12I, op_sj20, 0)

`define LA_DEC_BSTRINS(__is_w, __msbd, __lsbd) begin \
    uop_bstr_pl.is_w = __is_w; \
    uop_bstr_pl.is_ins = 1; \
    uop_bstr_pl.msbw = __msbd; \
    uop_bstr_pl.lsbw = __lsbd; \
    `LA_DEC(BitStr, uop_bstr_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
    `LA_DEC_REG_R_GPR(1, op_rd) \
  end

`define LA_DECODE_INST_BSTRINS_D `LA_DEC_BSTRINS(0, op_msbd, op_lsbd)
`define LA_DECODE_INST_BSTRINS_W `LA_DEC_BSTRINS(1, {1'b0, op_msbw}, {1'b0,op_lsbw})

`define LA_DEC_BSTRPICK(__is_w, __msbd, __lsbd) begin \
    uop_bstr_pl.is_w = __is_w; \
    uop_bstr_pl.is_ins = 0; \
    uop_bstr_pl.msbw = __msbd; \
    uop_bstr_pl.lsbw = __lsbd; \
    `LA_DEC(BitStr, uop_bstr_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
  end

`define LA_DECODE_INST_BSTRPICK_D `LA_DEC_BSTRPICK(0, op_msbd, op_lsbd)
`define LA_DECODE_INST_BSTRPICK_W `LA_DEC_BSTRPICK(1, {1'b0, op_msbw}, {1'b0,op_lsbw})

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

`define LA_DEC_COND_BR(__ty, __rr0, __rr1, __offs21) begin \
    uop_cond_br_pl.offs21 = __offs21; \
    uop_cond_br_pl.ty = BrCond``__ty; \
    `LA_DEC(CondBr, uop_cond_br_pl) \
    `LA_DEC_REG_R_GPR(0, __rr0) \
    `LA_DEC_REG_R_GPR(1, __rr1) \
  end

`define LA_DECODE_INST_BEQ `LA_DEC_COND_BR(Eq, op_rd, op_rj, 21'(signed'(op_offs16)))
`define LA_DECODE_INST_BNE `LA_DEC_COND_BR(Ne, op_rd, op_rj, 21'(signed'(op_offs16)))
`define LA_DECODE_INST_BGT `LA_DEC_COND_BR(GtS, op_rd, op_rj, 21'(signed'(op_offs16)))
`define LA_DECODE_INST_BGTU `LA_DEC_COND_BR(GtU, op_rd, op_rj, 21'(signed'(op_offs16)))
`define LA_DECODE_INST_BLE `LA_DEC_COND_BR(LeS, op_rd, op_rj, 21'(signed'(op_offs16)))
`define LA_DECODE_INST_BLEU `LA_DEC_COND_BR(LeU, op_rd, op_rj, 21'(signed'(op_offs16)))

`define LA_DECODE_INST_BEQZ `LA_DEC_COND_BR(Eq, op_rd, 0, op_offs21)
`define LA_DECODE_INST_BNEZ `LA_DEC_COND_BR(Ne, op_rd, 0, op_offs21)

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

`define LA_DEC_MEM_BC_LD(__ty, __chk) \
  begin \
    uop_mem_pl.is_store = '0; \
    uop_mem_pl.ty = MemOpType``__ty; \
    uop_mem_pl.is_unsigned = 0; \
    uop_mem_pl.check_``__chk = '1; \
    `LA_DEC(Mem, uop_mem_pl) \
    `LA_DEC_REG_W_GPR(0, op_rd) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
    `LA_DEC_REG_R_GPR(1, op_rk) \
  end

`define LA_DEC_MEM_BC_ST(__ty, __chk) \
  begin \
    uop_mem_pl.is_store = '1; \
    uop_mem_pl.ty = MemOpType``__ty; \
    uop_mem_pl.is_unsigned = '0; \
    uop_mem_pl.check_``__chk = '1; \
    `LA_DEC(Mem, uop_mem_pl) \
    `LA_DEC_REG_R_GPR(0, op_rj) \
    `LA_DEC_REG_R_GPR(1, op_rk) \
    `LA_DEC_REG_R_GPR(2, op_rd) \
  end

`define LA_DECODE_INST_LDGT_B `LA_DEC_MEM_BC_LD(B, gt)
`define LA_DECODE_INST_LDGT_H `LA_DEC_MEM_BC_LD(H, gt)
`define LA_DECODE_INST_LDGT_W `LA_DEC_MEM_BC_LD(W, gt)
`define LA_DECODE_INST_LDGT_D `LA_DEC_MEM_BC_LD(D, gt)
`define LA_DECODE_INST_LDLE_B `LA_DEC_MEM_BC_LD(B, le)
`define LA_DECODE_INST_LDLE_H `LA_DEC_MEM_BC_LD(H, le)
`define LA_DECODE_INST_LDLE_W `LA_DEC_MEM_BC_LD(W, le)
`define LA_DECODE_INST_LDLE_D `LA_DEC_MEM_BC_LD(D, le)

`define LA_DECODE_INST_STGT_B `LA_DEC_MEM_BC_ST(B, gt)
`define LA_DECODE_INST_STGT_H `LA_DEC_MEM_BC_ST(H, gt)
`define LA_DECODE_INST_STGT_W `LA_DEC_MEM_BC_ST(W, gt)
`define LA_DECODE_INST_STGT_D `LA_DEC_MEM_BC_ST(D, gt)
`define LA_DECODE_INST_STLE_B `LA_DEC_MEM_BC_ST(B, le)
`define LA_DECODE_INST_STLE_H `LA_DEC_MEM_BC_ST(H, le)
`define LA_DECODE_INST_STLE_W `LA_DEC_MEM_BC_ST(W, le)
`define LA_DECODE_INST_STLE_D `LA_DEC_MEM_BC_ST(D, le)

`define LA_DECODE_INST_DBAR is_nop = 1;
`define LA_DECODE_INST_IBAR begin \
    uop_br_pl.offs26 = 'sd4; \
    uop_br_pl.base_reg = 0; \
    `LA_DEC(Br, uop_br_pl) \
  end

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

  always_comb begin
    // Operands
    automatic virt_reg_t op_rd = in.inst[4:0];
    automatic virt_reg_t op_rj = in.inst[9:5];
    automatic virt_reg_t op_rk = in.inst[14:10];
    automatic logic unsigned [11:0] op_uk12 = in.inst[21:10];
    automatic logic signed [11:0] op_sk12 = signed'(in.inst[21:10]);
    automatic logic signed [13:0] op_sk14 = signed'(in.inst[23:10]);
    automatic logic signed [15:0] op_sk16 = signed'(in.inst[25:10]);
    automatic logic signed [19:0] op_sj20 = signed'(in.inst[24:5]);
    automatic logic signed [25:0] op_offs26 = signed'({in.inst[9:0], in.inst[25:10]});
    automatic logic signed [20:0] op_offs21 = signed'({in.inst[4:0], in.inst[25:10]});
    automatic logic signed [15:0] op_offs16 = signed'(in.inst[25:10]);
    automatic logic unsigned [4:0] op_lsbw = in.inst[14:10];
    automatic logic unsigned [4:0] op_msbw = in.inst[20:16];
    automatic logic unsigned [5:0] op_lsbd = in.inst[15:10];
    automatic logic unsigned [5:0] op_msbd = in.inst[21:16];
    automatic logic unsigned [1:0] op_sa2 = in.inst[16:15];
    automatic logic unsigned [2:0] op_sa3 = in.inst[17:15];

    // UOp payloads
    automatic inst_pkg::uop_add_pl_t uop_add_pl = '0;
    automatic inst_pkg::uop_bitop_pl_t uop_bitop_pl = '0;
    automatic inst_pkg::uop_ld_imm_pl_t uop_ld_imm_pl = '0;
    automatic inst_pkg::uop_bstr_pl_t uop_bstr_pl = '0;
    automatic inst_pkg::uop_br_pl_t uop_br_pl = '0;
    automatic inst_pkg::uop_cond_br_pl_t uop_cond_br_pl = '0;
    automatic inst_pkg::uop_mem_pl_t uop_mem_pl = '0;

    // Default assignments
    out.inst.op = inst_pkg::inst_opcode_t'(0);
    out.inst.pl = '0;
    out.inst.vregs_r = '0;
    out.inst.vregs_w = '0;

    is_nop = 0;
    invalid_inst = 0;

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
