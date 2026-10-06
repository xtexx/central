`timescale 1ns / 1ps
`default_nettype wire

// Configurable fractional frequency divider.
module freq_div
  import inst_pkg::*;
#(
    // 1 < floor(division ratio) < (2**RATIO_W) - 1
    parameter int unsigned RATIO_W   = 16,
    // division ratio resolution = 1 / PATTERN_N
    // Must be power of 2
    parameter int unsigned PATTERN_N = 4
) (
    input logic clk_in,
    input logic [PATTERN_N-1:0][RATIO_W-1:0] cfg_pattern,
    output bit clk_out
);

  parameter int unsigned PATTERN_W = $clog2(PATTERN_N);

  bit   [PATTERN_W-1:0] pattern_cnt;
  bit   [  RATIO_W-1:0] ratio_cnt;

  logic [  RATIO_W-1:0] current_phase;
  assign current_phase = cfg_pattern[pattern_cnt];

  always_ff @(posedge clk_in) begin
    if (ratio_cnt == (current_phase >> 1)) clk_out <= ~clk_out;

    ratio_cnt <= ratio_cnt + 1;
    if (ratio_cnt == current_phase) begin
      // Next phase
      pattern_cnt <= pattern_cnt + 1;
      ratio_cnt   <= 0;
    end
  end

endmodule
