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
  logic unsigned [63:0] tmp_u64;
  logic unsigned [31:0] tmp_u32;

  inst_pkg::uop_add_pl_t uop_add_pl;
  inst_pkg::uop_bitop_pl_t uop_bitop_pl;
  inst_pkg::uop_ld_imm_pl_t uop_ld_imm_pl;
  inst_pkg::uop_bstr_pl_t uop_bstr_pl;

  always_comb begin
    // Payload decode
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
    tmp_u64 = '0;
    tmp_u32 = '0;
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
          BitOpTyAndImm: rd = rj & 64'(uop_bitop_pl.ui12);
          BitOpTyOrImm:  rd = rj | 64'(uop_bitop_pl.ui12);
          BitOpTyXorImm: rd = rj ^ 64'(uop_bitop_pl.ui12);

          BitOpTyAnd:  rd = rj & rk;
          BitOpTyOr:   rd = rj | rk;
          BitOpTyAndn: rd = rj & (~rk);
          BitOpTyOrn:  rd = rj | (~rk);

          BitOpTyXor: rd = rj ^ rk;
          BitOpTyNor: rd = ~(rj | rk);

          BitOpTyMaskEqz: rd = (rk == 0) ? '0 : rj;
          BitOpTyMaskNez: rd = (rk != 0) ? '0 : rj;

          BitOpTyBitRevW: begin
            tmp_u32 = {<<{rj[31:0]}};
            rd = 64'(signed'(tmp_u32));
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
            // TODO
          end
        endcase
      end
      UOpLdImm: begin
        unique case (uop_ld_imm_pl.op)
          LdImmOpLU12IW: begin
            // LU12I.W:
            // GR[rd] = SignExtend({si20, 12'b0}, GRLEN)
            rd = 64'(signed'({uop_ld_imm_pl.imm[19:0], 12'b0}));
          end
          LdImmOpCU32ID: begin
            // LU32I.D:
            // GR[rd] = {SignExtend(si20, 32), GR[rd][31:0]}
            rd = {unsigned'(32'(signed'(uop_ld_imm_pl.imm[19:0]))), rj[31:0]};
          end
          LdImmOpCU52ID: begin
            // LU52I.D:
            // GR[rd] = {si12, GR[rj][51:0]}
            rd = {uop_ld_imm_pl.imm[11:0], rj[51:0]};
          end
          LdImmOpPCADDU2I: begin
            // PCADDI:
            // GR[rd] = PC + SignExtend({si20, 2'b0}, GRLEN)
            rd = rob_pc_rd.pc + 64'(signed'({uop_ld_imm_pl.imm[19:0], 2'b00}));
          end
          LdImmOpPCADDU12I: begin
            // PCADDU12I:
            // GR[rd] = PC + SignExtend({si20, 12'b0}, GRLEN)
            rd = rob_pc_rd.pc + 64'(signed'({uop_ld_imm_pl.imm[19:0], 12'b0}));
          end
          LdImmOpPCADDU18I: begin
            // PCADDU18I:
            // GR[rd] = PC + SignExtend({si20, 18'b0}, GRLEN)
            rd = rob_pc_rd.pc + 64'(signed'({uop_ld_imm_pl.imm[19:0], 18'b0}));
          end
          LdImmOpPCALAU12I: begin
            // PCALAU12I:
            // tmp_u64 = PC + SignExtend({si20, 12'b0}, GRLEN)
            rd = rob_pc_rd.pc + 64'(signed'({uop_ld_imm_pl.imm[19:0], 12'b0}));
            // GR[rd] = {tmp_u64[GRLEN-1:12], 12'b0}
            rd = {rd[63:12], 12'b0};
          end
        endcase
      end
      UOpBitStr: begin
        tmp_u64 = '0;
        for (int i = 0; i < 64; i++) begin
          if (i >= uop_bstr_pl.lsbw && i <= uop_bstr_pl.msbw) tmp_u64[i] = 1'b1;
        end
        if (uop_bstr_pl.is_ins) begin
          rd = (rk & ~tmp_u64) | ((rj << uop_bstr_pl.lsbw) & tmp_u64);
        end else begin
          rd = (rj & tmp_u64) >> uop_bstr_pl.lsbw;
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

endmodule
