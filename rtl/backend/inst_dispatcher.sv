`timescale 1ns / 1ps
`default_nettype wire

// Instruction Dispatcher, combinational logic
module inst_dispatcher
  import inst_pkg::*;
(
    rr_out_if.rx in,
    rr_out_if.tx o_alu,
    rr_out_if.tx o_ctl,
    rr_out_if.tx o_bru,
    rr_out_if.tx o_agu,
    rr_out_if.tx o_mul
);

  always_comb begin
    // Instruction data wire net
    o_alu.inst = in.inst;
    o_ctl.inst = in.inst;
    o_bru.inst = in.inst;
    o_agu.inst = in.inst;
    o_mul.inst = in.inst;

    // Default assignments
    o_alu.valid = '0;
    o_ctl.valid = '0;
    o_bru.valid = '0;
    o_agu.valid = '0;
    o_mul.valid = '0;

    // Before the first instruction, RR output opcode are 'x.
    // In this case, ready wire should be pulled down stably.
    in.ready = '0;

    // Dispatch
    unique case (in.inst.op)
      // ALU
      UOpAdd, UOpAddImm, UOpBitOp, UOpLdImm, UOpBitStr, UOpBitShift: begin
        o_alu.valid = in.valid;
        in.ready = o_alu.ready;
      end
      // Control
      UOpException: begin
        o_ctl.valid = in.valid;
        in.ready = o_ctl.ready;
      end
      // BRU
      UOpBr, UOpCondBr: begin
        o_bru.valid = in.valid;
        in.ready = o_bru.ready;
      end
      // AGU
      UOpMem: begin
        o_agu.valid = in.valid;
        in.ready = o_agu.ready;
      end
      // MUL
      UOpMul, UOpDiv: begin
        o_mul.valid = in.valid;
        in.ready = o_mul.ready;
      end
    endcase
  end

endmodule
