`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"
`include "../macros/errors.svh"

// Branch Execute Unit
module bru_exec
  import inst_pkg::*;
(
    input logic clk,
    input logic rst,
    rr_out_if.rx in,
    prf_read_if.user prf_rd[2],
    prf_write_if.user prf_wr,
    rob_pc_read_if.user rob_pc_rd,
    rob_execute_if.exec rob_ex,
    btq_addr_if.tx btq_push
);

  `ASSERT_STABLE(InstStable, in.valid, in.ready, in.inst, '0, clk, rst);

  logic ready;
  logic [63:0] rr0, rr1, target_vaddr;
  logic br_taken;

  inst_pkg::uop_br_pl_t uop_br_pl;
  inst_pkg::uop_cond_br_pl_t uop_cond_br_pl;

  always_comb begin
    // Payload decode
    uop_br_pl = in.inst.pl[$bits(inst_pkg::uop_br_pl_t)-1:0];
    uop_cond_br_pl = in.inst.pl[$bits(inst_pkg::uop_cond_br_pl_t)-1:0];

    // Read operand registers
    prf_rd[0].preg = in.inst.pregs_r[0];
    prf_rd[1].preg = in.inst.pregs_r[1];
    rr0 = prf_rd[0].data;
    rr1 = prf_rd[1].data;

    // Read PC
    rob_pc_rd.idx = in.inst.rob_idx;

    // Wait for operand
    ready = !rst && in.valid && prf_rd[0].ready && prf_rd[1].ready;

    // Perform calculation
    br_taken = '0;
    target_vaddr = '0;
    unique case (in.inst.op)
      UOpBr: begin
        br_taken = '1;
        target_vaddr = (uop_br_pl.base_reg ? rr0 : rob_pc_rd.pc)
          + 64'(signed'({uop_br_pl.offs26, 2'b0}));
      end
      UOpCondBr: begin
        unique case (uop_cond_br_pl.ty)
          BrCondEq:  br_taken = (rr0 == rr1);
          BrCondNe:  br_taken = (rr0 != rr1);
          BrCondGtS: br_taken = (signed'(rr0) > signed'(rr1));
          BrCondGtU: br_taken = (unsigned'(rr0) > unsigned'(rr1));
          BrCondLeS: br_taken = (signed'(rr0) <= signed'(rr1));
          BrCondLeU: br_taken = (unsigned'(rr0) <= unsigned'(rr1));
        endcase
        target_vaddr = rob_pc_rd.pc + 64'(signed'({uop_cond_br_pl.offs21, 2'b0}));
      end
      default: if (ready) `ERROR("BRU Exec: bad op");
    endcase

    // Write to BTQ
    btq_push.hi32 = target_vaddr[63:32];
    btq_push.valid = ready && br_taken;
    ready = ready && (btq_push.ready || !br_taken);

    // Write to destination register
    prf_wr.preg = in.inst.pregs_w[0];
    prf_wr.data = rob_pc_rd.pc + 4;
    prf_wr.valid = ready;

    // Pop instruction from DQ
    in.ready = ready;

    // ROB write back
    rob_ex.idx = in.inst.rob_idx;
    rob_ex.commit_type = (br_taken ? InstCommitBranch : InstCommitNop);
    rob_ex.data = target_vaddr[31:0];
    rob_ex.valid = ready;
  end

endmodule
