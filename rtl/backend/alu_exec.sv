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
    rob_pc_read_if.user rob_pc_rd,
    rob_execute_if.exec rob_ex
);

  `ASSERT_STABLE(InstStable, in.valid, in.ready, in.inst, '0, clk, rst);

  logic ready;
  logic [63:0] rd, rj, rk;

  logic [63:0] ctz_in;
  logic [63:0] ctz_out, clz_out;
  logic ctz_empty, clz_empty;
  assign ctz_out[63:6] = '0;
  assign clz_out[63:6] = '0;
  cc_lzc #(
      .Width(64),
      .Mode (cc_pkg::LZC_TRAILING_ZERO_CNT)
  ) i_ctz (
      .in_i   (ctz_in),
      .cnt_o  (ctz_out[5:0]),
      .empty_o(ctz_empty)
  );
  cc_lzc #(
      .Width(64),
      .Mode (cc_pkg::LZC_LEADING_ZERO_CNT)
  ) i_clz (
      .in_i   (ctz_in),
      .cnt_o  (clz_out[5:0]),
      .empty_o(clz_empty)
  );

  always_comb begin
    // Payload decode
    automatic inst_pkg::uop_add_pl_t uop_add_pl;
    automatic inst_pkg::uop_bitop_pl_t uop_bitop_pl;
    automatic inst_pkg::uop_ld_imm_pl_t uop_ld_imm_pl;
    automatic inst_pkg::uop_bstr_pl_t uop_bstr_pl;
    uop_add_pl = in.inst.pl[$bits(inst_pkg::uop_add_pl_t)-1:0];
    uop_bitop_pl = in.inst.pl[$bits(inst_pkg::uop_bitop_pl_t)-1:0];
    uop_ld_imm_pl = in.inst.pl[$bits(inst_pkg::uop_ld_imm_pl_t)-1:0];
    uop_bstr_pl = in.inst.pl[$bits(inst_pkg::uop_bstr_pl_t)-1:0];

    // Read operand registers
    prf_rd[0].preg = in.inst.pregs_r[0];
    prf_rd[1].preg = in.inst.pregs_r[1];
    rj = prf_rd[0].data;
    rk = prf_rd[1].data;

    // Read PC
    rob_pc_rd.idx = in.inst.rob_idx;

    // Wait for operand
    ready = !rst && in.valid && prf_rd[0].ready && prf_rd[1].ready;

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
      UOpBitOp: begin
        unique case (uop_bitop_pl.ty)
          BitOpTyAndImm: rd = rj & 64'(uop_bitop_pl.ui16[11:0]);
          BitOpTyOrImm:  rd = rj | 64'(uop_bitop_pl.ui16[11:0]);
          BitOpTyXorImm: rd = rj ^ 64'(uop_bitop_pl.ui16[11:0]);

          BitOpTyAddu16id: rd = rj + 64'(signed'({uop_bitop_pl.ui16[15:0], 16'b0}));

          BitOpTyAnd:  rd = rj & rk;
          BitOpTyOr:   rd = rj | rk;
          BitOpTyAndn: rd = rj & (~rk);
          BitOpTyOrn:  rd = rj | (~rk);

          BitOpTyXor: rd = rj ^ rk;
          BitOpTyNor: rd = ~(rj | rk);

          BitOpTyMaskEqz: rd = (rk == 0) ? '0 : rj;
          BitOpTyMaskNez: rd = (rk != 0) ? '0 : rj;

          BitOpTyBitRevW: begin
            automatic logic [31:0] tmp = {<<{rj[31:0]}};
            rd = 64'(signed'(tmp));
          end
          BitOpTyBitRevD: rd = {<<{rj}};
          BitOpTyBitRev4B, BitOpTyBitRev8B: begin
            for (int i = 0; i < 8; i++) begin
              rd[i*8+:8] = {<<{rj[i*8+:8]}};
            end
            rd = (uop_bitop_pl.ty == BitOpTyBitRev4B) ? 64'(signed'(rd[31:0])) : rd;
          end

          BitOpTyRevH2W: rd = {rj[47:32], rj[63:48], rj[15:0], rj[31:16]};
          BitOpTyRevHD:  rd = {rj[15:0], rj[31:16], rj[47:32], rj[63:48]};
          BitOpTyRevB2H, BitOpTyRevB4H: begin
            for (int i = 0; i < 4; i++) begin
              rd[i*16+:16] = {rj[i*16+:8], rj[i*16+8+:8]};
            end
            rd = (uop_bitop_pl.ty == BitOpTyRevB2H) ? 64'(signed'(rd[31:0])) : rd;
          end
          BitOpTyRevB2W: begin
            rd[31:0]  = {rj[7:0], rj[15:8], rj[23:16], rj[31:24]};
            rd[63:32] = {rj[39:32], rj[47:40], rj[55:48], rj[63:56]};
          end
          BitOpTyRevBD:  rd = {<<8{rj}};

          BitOpTyExtWB: rd = 64'(signed'(rj[7:0]));
          BitOpTyExtWH: rd = 64'(signed'(rj[15:0]));

          BitOpTyCLOW,
          BitOpTyCLOD,
          BitOpTyCLZW,
          BitOpTyCLZD,
          BitOpTyCTOW,
          BitOpTyCTOD,
          BitOpTyCTZW,
          BitOpTyCTZD: begin
            automatic logic is_t = uop_bitop_pl.ty[2];
            rd = is_t ? (ctz_empty ? 64 : ctz_out) : (clz_empty ? 64 : clz_out);
          end

          BitOpTySetLtS: rd = (signed'(rj) < signed'(rk)) ? 1 : 0;
          BitOpTySetLtU: rd = (unsigned'(rj) < unsigned'(rk)) ? 1 : 0;
          BitOpTySetLtSImm: rd = (signed'(rj) < 64'(signed'(uop_bitop_pl.ui16[11:0]))) ? 1 : 0;
          BitOpTySetLtUImm: rd = (unsigned'(rj) < 64'(signed'(uop_bitop_pl.ui16[11:0]))) ? 1 : 0;

          BitOpTySlAddW, BitOpTySlAddWU: begin
            automatic logic is_u = uop_bitop_pl.ty[0];
            automatic logic [1:0] op_sa2 = uop_bitop_pl.ui16[1:0];
            automatic logic [31:0] tmp = '0;
            for (int i = 0; i < 4; i++) begin
              if (op_sa2 == 2'(i)) begin
                tmp = rj[31:0] << (i + 1);
              end
            end
            rd = is_u ? 64'(unsigned'(rk[31:0] + tmp)) : 64'(signed'(rk[31:0] + tmp));
          end
          BitOpTySlAddD: begin
            automatic logic [ 1:0] op_sa2 = uop_bitop_pl.ui16[1:0];
            automatic logic [63:0] tmp = '0;
            for (int i = 0; i < 4; i++) begin
              if (op_sa2 == 2'(i)) begin
                tmp = rj << (i + 1);
              end
            end
            rd = tmp + rk;
          end

          BitOpTyBytePickW: begin
            automatic logic [ 1:0] op_sa2 = uop_bitop_pl.ui16[1:0];
            // tmp = {GR[rk][31:0], GR[rj][31:0]}
            automatic logic [63:0] tmp = {rk[31:0], rj[31:0]};
            // GR[rd] = SignExtend(tmp[8*(8-sa2)-1 : 8*(4-sa2)], GRLEN)
            automatic logic [31:0] out = '0;
            for (int i = 0; i < 4; i++) begin
              if (op_sa2 == 2'(i)) begin
                out = tmp[8*(4-i)+:32];
              end
            end
            rd = 64'(signed'(out));
          end
          BitOpTyBytePickD: begin
            automatic logic [  2:0] op_sa3 = uop_bitop_pl.ui16[2:0];
            // tmp = {GR[rk][63:0], GR[rj][63:0]}
            automatic logic [127:0] tmp = {rk, rj};
            // GR[rd] = tmp[8*(16-sa3)-1 : 8*(8-sa3)]
            for (int i = 0; i < 8; i++) begin
              if (op_sa3 == 3'(i)) begin
                rd = tmp[8*(8-i)+:64];
              end
            end
          end
        endcase
      end
      UOpLdImm: begin
        unique case (uop_ld_imm_pl.op)
          LdImmOpLU12IW: begin
            // GR[rd] = SignExtend({si20, 12'b0}, GRLEN)
            rd = 64'(signed'({uop_ld_imm_pl.imm[19:0], 12'b0}));
          end
          LdImmOpCU32ID: begin
            // GR[rd] = {SignExtend(si20, 32), GR[rd][31:0]}
            rd = {unsigned'(32'(signed'(uop_ld_imm_pl.imm[19:0]))), rj[31:0]};
          end
          LdImmOpCU52ID: begin
            // GR[rd] = {si12, GR[rj][51:0]}
            rd = {uop_ld_imm_pl.imm[11:0], rj[51:0]};
          end
          LdImmOpPCADDU2I: begin
            // GR[rd] = PC + SignExtend({si20, 2'b0}, GRLEN)
            rd = rob_pc_rd.pc + 64'(signed'({uop_ld_imm_pl.imm[19:0], 2'b00}));
          end
          LdImmOpPCADDU12I: begin
            // GR[rd] = PC + SignExtend({si20, 12'b0}, GRLEN)
            rd = rob_pc_rd.pc + 64'(signed'({uop_ld_imm_pl.imm[19:0], 12'b0}));
          end
          LdImmOpPCADDU18I: begin
            // GR[rd] = PC + SignExtend({si20, 18'b0}, GRLEN)
            rd = rob_pc_rd.pc + 64'(signed'({uop_ld_imm_pl.imm[19:0], 18'b0}));
          end
          LdImmOpPCALAU12I: begin
            // tmp = PC + SignExtend({si20, 12'b0}, GRLEN)
            rd = rob_pc_rd.pc + 64'(signed'({uop_ld_imm_pl.imm[19:0], 12'b0}));
            // GR[rd] = {tmp[GRLEN-1:12], 12'b0}
            rd = {rd[63:12], 12'b0};
          end
        endcase
      end
      UOpBitStr: begin
        automatic logic [63:0] tmp = '0;
        for (int i = 0; i < 64; i++) begin
          if (i >= uop_bstr_pl.lsbw && i <= uop_bstr_pl.msbw) tmp[i] = 1'b1;
        end
        if (uop_bstr_pl.is_ins) begin
          rd = (rk & ~tmp) | ((rj << uop_bstr_pl.lsbw) & tmp);
        end else begin
          rd = (rj & tmp) >> uop_bstr_pl.lsbw;
        end
        // rd = IS_W ? SignExtend(rd[31:0]) : rd
        rd = (uop_bstr_pl.is_w) ? unsigned'(64'(signed'(rd[31:0]))) : rd;
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

  // Trailing/leading one/zero counter
  always_comb begin
    /* verilator lint_off UNUSEDSIGNAL */
    automatic inst_pkg::uop_bitop_pl_t uop_bitop_pl;
    /* verilator lint_on UNUSEDSIGNAL */
    automatic logic is_w;
    automatic logic is_z;

    uop_bitop_pl = in.inst.pl[$bits(inst_pkg::uop_bitop_pl_t)-1:0];
    is_w = ~uop_bitop_pl.ty[0];
    is_z = uop_bitop_pl.ty[1];

    ctz_in = prf_rd[0].data;
    ctz_in = is_z ? ctz_in : (~ctz_in);
    if (is_w) begin
      ctz_in = {ctz_in[31:0], {32{(is_z) ? (1'b1) : (1'b0)}}};
    end
  end

endmodule
