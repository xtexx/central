`timescale 1ns / 1ps
`default_nettype wire

// Instruction Dispatcher, combinational logic
module inst_dispatcher
  import inst_pkg::*;
(
    rr_out_if.rx in,
    rr_out_if.tx o_alu,
    rr_out_if.tx o_ctl
);

  always_comb begin
    // Instruction data wire net
    o_alu.inst  = in.inst;
    o_ctl.inst  = in.inst;

    // Default assignments
    o_alu.valid = '0;
    o_ctl.valid = '0;

    // Dispatch
    unique case (in.inst.op)
      // ALU
      UOpAdd, UOpAddImm, UOpBitOpImm: begin
        o_alu.valid = in.valid;
        in.ready = o_alu.ready;
      end
      // Control
      UOpException: begin
        o_ctl.valid = in.valid;
        in.ready = o_ctl.ready;
      end
    endcase
  end

endmodule
