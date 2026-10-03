`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"
`include "../macros/errors.svh"

// Misc Control Instructions Execute Unit
module ctl_exec
  import inst_pkg::*;
(
    input logic clk,
    input logic rst,
    rr_out_if.rx in,
    rob_execute_if.exec rob_ex
);

  `ASSERT_STABLE(InstStable, in.valid, in.ready, in.inst, '0, clk, rst);

  logic ready;

  always_comb begin
    // Wait for operand
    ready = !rst && in.valid;

    // Perform calculation
    rob_ex.commit_type = InstCommitNop;
    rob_ex.data = '0;
    unique case (in.inst.op)
      UOpException: begin
        rob_ex.commit_type = InstCommitException;
        rob_ex.data = in.inst.pl;
      end
      default: if (ready) `ERROR("CTL Exec: bad op");
    endcase

    // Pop instruction from DQ
    in.ready = ready;

    // ROB write back
    rob_ex.idx = in.inst.rob_idx;
    rob_ex.valid = ready;
  end

endmodule
