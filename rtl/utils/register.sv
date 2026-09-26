`timescale 1ns / 1ps
`default_nettype none

module register #(
    parameter type T = logic,
    parameter T RESET_VAL = T'(0)
) (
    input logic clk,
    input logic rst,
    input T din,
    output T dout,
    input logic wen
);
  always @(posedge clk) begin
    if (rst) dout <= RESET_VAL;
    else if (wen) dout <= din;
  end
endmodule
