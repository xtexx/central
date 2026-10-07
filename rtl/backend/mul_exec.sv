`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"
`include "../macros/errors.svh"

// Multiplier Unit
module mul_exec
  import inst_pkg::*;
(
    input logic clk,
    input logic rst,
    rr_out_if.rx in,
    prf_read_if.user prf_rd[2],
    prf_write_if.user prf_wr,
    rob_execute_if.exec rob_ex
);

  `ASSERT_STABLE(InstStable, in.valid, in.ready, in.inst, '0, clk, rst);

  logic ready;
  logic [63:0] result;

  typedef enum logic [2:0] {
    FSMIdle,
    FSMMultiply,
    FSMWriteBack
  } fsm_state_t;
  fsm_state_t state;

  logic [64:0] lhs, rhs;
  logic [129:0] mul_out;
  logic mul_valid, mul_ready;
  booth_mul #(
      .WIDTH(65),
      .BATCH_SIZE(1)
  ) i_mul (
      .clk(clk),
      .rst(rst),
      .valid(mul_valid),
      .lhs(lhs),
      .rhs(rhs),
      .ready(mul_ready),
      .result(mul_out)
  );
  assign mul_valid = (state == FSMMultiply);
  logic [65:0] unused_mul_out;
  assign unused_mul_out = mul_out[129:64];

  // Read operand registers
  assign prf_rd[0].preg = in.inst.pregs_r[0];
  assign prf_rd[1].preg = in.inst.pregs_r[1];

  // Wait for operand
  assign ready = !rst && in.valid && prf_rd[0].ready && prf_rd[1].ready;

  // Pop instruction from DQ
  assign in.ready = (state == FSMWriteBack);

  // Write back result
  assign prf_wr.preg = in.inst.pregs_w[0];
  assign prf_wr.data = result;
  assign prf_wr.valid = (state == FSMWriteBack);

  // ROB write back
  assign rob_ex.idx = in.inst.rob_idx;
  assign rob_ex.commit_type = InstCommitNop;
  assign rob_ex.data = '0;
  assign rob_ex.valid = (state == FSMWriteBack);

  // Calculate operands
  always_comb begin
    lhs = {1'b0, prf_rd[0].data};
    rhs = {1'b0, prf_rd[1].data};
    // pl[0] -> is_signed; pl[1] -> is_w
    unique case (in.inst.pl[1:0])
      2'b00: begin
        lhs = 65'(unsigned'(lhs[63:0]));
        rhs = 65'(unsigned'(rhs[63:0]));
      end
      2'b01: begin
        lhs = 65'(unsigned'(lhs[31:0]));
        rhs = 65'(unsigned'(rhs[31:0]));
      end
      2'b10: begin
        lhs = 65'(signed'(lhs[63:0]));
        rhs = 65'(signed'(rhs[63:0]));
      end
      2'b11: begin
        lhs = 65'(signed'(lhs[31:0]));
        rhs = 65'(signed'(rhs[31:0]));
      end
    endcase
  end

  // Select output
  always_comb begin
    result = '0;
    // pl[3:2] -> 00: [31:0], 01: [63:32]
    // pl[3:2] -> 10: [63:0], 11: [127:64]
    unique case (in.inst.pl[3:2])
      2'b00: result = 64'(signed'(mul_out[31:0]));
      2'b01: result = 64'(signed'(mul_out[63:32]));
      2'b10: result = mul_out[63:0];
      2'b11: result = mul_out[127:64];
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst || !ready) begin
      // FSM should be reset to Idle if ready is de-asserted, for example,
      // when the pipeline is flushed.
      state <= FSMIdle;
    end else begin
      unique if (state == FSMIdle) begin
        state <= FSMMultiply;
      end else if (state == FSMMultiply) begin
        if (mul_ready) state <= FSMWriteBack;
      end else if (state == FSMWriteBack) begin
        state <= FSMIdle;
      end
    end
  end

endmodule
