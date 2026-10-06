`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"
`include "../macros/errors.svh"

// Address Generator Unit
module agu_exec
  import inst_pkg::*;
(
    input logic clk,
    input logic rst,
    rr_out_if.rx in,
    prf_read_if.user prf_rd[3],
    rob_execute_if.exec rob_ex,
    lsq_if.tx lsq_push
);

  `ASSERT_STABLE(InstStable, in.valid, in.ready, in.inst, '0, clk, rst);

  inst_pkg::uop_mem_pl_t uop_pl;
  inst_pkg::lsq_entry_t  lsq_ent;

  always_comb begin
    automatic logic ready, trigger_bce;
    automatic logic [63:0] rr0, rr1, rr2, vaddr;
    // Payload decode
    uop_pl = in.inst.pl[$bits(inst_pkg::uop_mem_pl_t)-1:0];

    // Read operand registers
    prf_rd[0].preg = in.inst.pregs_r[0];
    prf_rd[1].preg = in.inst.pregs_r[1];
    prf_rd[2].preg = in.inst.pregs_r[2];
    rr0 = prf_rd[0].data;
    rr1 = prf_rd[1].data;
    rr2 = prf_rd[2].data;

    // Wait for operand
    ready = !rst && in.valid && prf_rd[0].ready && prf_rd[1].ready && prf_rd[2].ready;

    // Perform calculation
    vaddr = (uop_pl.check_gt || uop_pl.check_le) ? rr0 : (rr0 + rr1 + 64'(signed'(uop_pl.offs)));
    unique if (uop_pl.check_gt) begin
      trigger_bce = !(unsigned'(rr0) > unsigned'(rr1));
    end else if (uop_pl.check_le) begin
      trigger_bce = !(unsigned'(rr0) <= unsigned'(rr1));
    end else begin
      trigger_bce = '0;
    end
    lsq_ent = '0;
    lsq_ent.is_store = uop_pl.is_store;
    lsq_ent.addr = vaddr;
    lsq_ent.strb = '0;
    unique case (uop_pl.ty)
      MemOpTypeB: lsq_ent.strb = 8'b00000001;
      MemOpTypeH: lsq_ent.strb = 8'b00000011;
      MemOpTypeW: lsq_ent.strb = 8'b00001111;
      MemOpTypeD: lsq_ent.strb = 8'b11111111;
    endcase
    lsq_ent.strb = lsq_ent.strb << vaddr[2:0];
    if (!uop_pl.is_store) begin
      lsq_ent.u.ld.shr = vaddr[2:0];
      if (uop_pl.is_unsigned) begin
        assert (!uop_pl.is_store);
        lsq_ent.u.ld.ext = 3;  // NOP
      end else begin
        unique case (uop_pl.ty)
          MemOpTypeB: lsq_ent.u.ld.ext = 0;
          MemOpTypeH: lsq_ent.u.ld.ext = 1;
          MemOpTypeW: lsq_ent.u.ld.ext = 2;
          MemOpTypeD: lsq_ent.u.ld.ext = 3;
        endcase
      end
      lsq_ent.u.ld.dst = in.inst.pregs_w[0];
    end else begin
      lsq_ent.u.st.data = rr2 << vaddr[2:0];
    end

    // Write to LSQ
    lsq_push.entry = lsq_ent;
    lsq_push.valid = ready;
    ready = ready && lsq_push.ready;

    // Pop instruction from DQ
    in.ready = ready;

    // ROB write back
    rob_ex.idx = in.inst.rob_idx;
    rob_ex.commit_type = trigger_bce ? InstCommitException : InstCommitMem;
    rob_ex.data = 'h0A; // Ecode = BCE; unused for InstCommitMem
    rob_ex.valid = ready;
  end

endmodule
