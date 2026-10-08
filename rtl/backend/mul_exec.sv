`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"
`include "../macros/errors.svh"

// Multiplier & divider Unit
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
    FSMDivide,
    FSMWriteBack
  } fsm_state_t;
  fsm_state_t state;

  logic [64:0] lhs, rhs;

  // Multiplier
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

  // Divider
  logic [63:0] div_numerator_q, div_numerator_d;
  logic [64:0] div_remainder_q, div_remainder_d;
  logic [63:0] div_quotient_q, div_quotient_d;
  logic div_sign;
  logic [5:0] div_cnt;

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
    div_sign = '0;
    unique0 if (in.inst.op == UOpMul) begin
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
    end else if (in.inst.op == UOpDiv) begin
      // pl[0] -> is_signed; pl[1] -> is_w
      unique case (in.inst.pl[1:0])
        2'b00: begin
          lhs = 65'(unsigned'(lhs[63:0]));
          rhs = 65'(unsigned'(rhs[63:0]));
        end
        2'b01: begin
          automatic logic [63:0] lhs_abs = lhs[63:0];
          automatic logic [63:0] rhs_abs = rhs[63:0];
          div_sign = in.inst.pl[2] ? lhs_abs[63] : (lhs_abs[63] ^ rhs_abs[63]);
          if (lhs_abs[63]) lhs_abs = 64'd0 - lhs_abs;
          if (rhs_abs[63]) rhs_abs = 64'd0 - rhs_abs;
          lhs = 65'(unsigned'(lhs_abs));
          rhs = 65'(unsigned'(rhs_abs));
        end
        2'b10: begin
          lhs = 65'(unsigned'(lhs[31:0]));
          rhs = 65'(unsigned'(rhs[31:0]));
        end
        2'b11: begin
          automatic logic [31:0] lhs_abs = lhs[31:0];
          automatic logic [31:0] rhs_abs = rhs[31:0];
          div_sign = in.inst.pl[2] ? lhs_abs[31] : (lhs_abs[31] ^ rhs_abs[31]);
          if (lhs_abs[31]) lhs_abs = 32'd0 - lhs_abs;
          if (rhs_abs[31]) rhs_abs = 32'd0 - rhs_abs;
          lhs = 65'(unsigned'(lhs_abs));
          rhs = 65'(unsigned'(rhs_abs));
        end
      endcase
    end
  end

  // Select output
  always_comb begin
    result = '0;
    unique0 if (in.inst.op == UOpMul) begin
      // pl[3:2] -> 00: [31:0], 01: [63:32]
      // pl[3:2] -> 10: [63:0], 11: [127:64]
      unique case (in.inst.pl[3:2])
        2'b00: result = 64'(signed'(mul_out[31:0]));
        2'b01: result = 64'(signed'(mul_out[63:32]));
        2'b10: result = mul_out[63:0];
        2'b11: result = mul_out[127:64];
      endcase
    end else if (in.inst.op == UOpDiv) begin
      // pl[1] -> is_w; pl[2] -> is_remainder
      if (in.inst.pl[2]) begin
        result = div_remainder_q[63:0];
      end else begin
        result = div_quotient_q;
      end
      if (div_sign) result = 64'd0 - result;
      if (in.inst.pl[1]) begin
        result = 64'(signed'(result[31:0]));
      end
    end
  end

  // Non-restoring divider
  always_comb begin
    div_numerator_d = div_numerator_q;
    div_remainder_d = div_remainder_q;
    div_quotient_d  = div_quotient_q;

    div_remainder_d = {div_remainder_d[63:0], div_numerator_d[63]};
    div_numerator_d = div_numerator_d << 1;

    if (div_remainder_d >= {1'b0, rhs[63:0]}) begin
      div_remainder_d = div_remainder_d - {1'b0, rhs[63:0]};
      div_quotient_d  = {div_quotient_d[62:0], 1'b1};
    end else begin
      div_quotient_d = {div_quotient_d[62:0], 1'b0};
    end
  end

  always_ff @(posedge clk) begin
    if (rst || !ready) begin
      // FSM should be reset to Idle if ready is de-asserted, for example,
      // when the pipeline is flushed.
      state <= FSMIdle;
    end else begin
      unique if (state == FSMIdle) begin
        unique if (in.inst.op == UOpMul) begin
          state <= FSMMultiply;
        end else if (in.inst.op == UOpDiv) begin
          div_numerator_q <= lhs[63:0];
          div_remainder_q <= 0;
          div_quotient_q <= 0;
          div_cnt <= 6'(64 - 1);
          state <= FSMDivide;
        end
      end else if (state == FSMMultiply) begin
        if (mul_ready) state <= FSMWriteBack;
      end else if (state == FSMDivide) begin
        div_numerator_q <= div_numerator_d;
        div_remainder_q <= div_remainder_d;
        div_quotient_q  <= div_quotient_d;
        if (div_cnt == 0) begin
          state <= FSMWriteBack;
        end
        div_cnt <= div_cnt - 1;
      end else if (state == FSMWriteBack) begin
        state <= FSMIdle;
      end
    end
  end
  // N = lhs div_numerator
  // D = rhs
  // Q := 0                  -- Initialize quotient and remainder to zero
  // R := 0
  // for i := n − 1 .. 0 do  -- Where n is number of bits in N
  //   R := R << 1           -- Left-shift R by 1 bit
  //   R(0) := div_numerator[0]          -- Set the least-significant bit of R equal to bit i of the numerator
  // div_numerator <= div_numerator>>1;
  //   if R ≥ D then
  //     R := R − D
  //     Q(i) := 1
  //   end
  // end

endmodule
