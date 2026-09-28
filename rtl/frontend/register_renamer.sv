`timescale 1ns / 1ps
`default_nettype wire

// Register Renames
// Updates RAT and allocates ROB entry
module register_renamer (
    input wire clk,
    input wire rst,
    ifu_out_if.rx ifu_if,
    rr_out_if.tx out_if
);

  import ifu_pkg::*;

  always_comb begin
    ifu_if.ready = 1;
  end

  always_ff @(posedge clk) begin
  end

endmodule
