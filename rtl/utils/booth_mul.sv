`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

module booth_mul #(
    parameter int WIDTH = 8,
    parameter int unsigned BATCH_SIZE = 2
) (
    input  logic                        clk,
    input  logic                        rst,
    input  logic                        valid,
    input  logic signed [    WIDTH-1:0] lhs,
    input  logic signed [    WIDTH-1:0] rhs,
    output logic                        ready,
    output logic signed [(2*WIDTH)-1:0] result
);

  localparam int unsigned CntW = cc_pkg::idx_width(WIDTH + 1 + 1);

  logic signed [2*WIDTH:0] p_q, p_d;
  logic [CntW-1:0] cnt;

  always_comb begin
    automatic logic signed [2*WIDTH:0] a, s;
    a[2*WIDTH:WIDTH+1] = lhs;
    a[WIDTH:0] = '0;
    s[2*WIDTH:WIDTH+1] = (WIDTH'(0)) - lhs;
    s[WIDTH:0] = '0;

    p_d = p_q;

    for (int i = 0; i < BATCH_SIZE; i++) begin
      if (p_q[1:0] == 2'b01) begin
        p_d = p_d + a;
      end else if (p_q[1:0] == 2'b10) begin
        p_d = p_d + s;
      end

      p_d = p_d >>> 1;
    end
  end

  assign ready  = (cnt == CntW'(WIDTH));
  assign result = p_q[2*WIDTH:1];

  always_ff @(posedge clk) begin
    if (rst || !valid) begin
      cnt <= CntW'(WIDTH + 1);
    end else if (cnt == CntW'(WIDTH + 1)) begin
      p_q <= {(WIDTH)'(0), rhs, 1'b0};
      cnt <= 0;
    end else if (!ready) begin
      p_q <= p_d;
      cnt <= cnt + CntW'(BATCH_SIZE);
    end
  end

  `ASSERT_INIT(WidthDividableByBatchSize, WIDTH % BATCH_SIZE == 0);
  `ASSERT_STABLE(OperandsStable, valid, ready, {lhs, rhs}, '0, clk, rst);

endmodule
