`timescale 1ns / 1ps
`default_nettype none

interface ftq_addr_if #(
    parameter int unsigned ADDR_W = 40
) (
    input logic clk,
    input logic rst
);

  logic [ADDR_W-1:0] addr;
  logic valid;
  logic ready;

  modport tx(output addr, valid, input ready);
  modport rx(input addr, valid, output ready);

  a_addr_known :
  assert property (@(posedge clk) disable iff (rst) (valid & ready) |-> !$isunknown(addr));

endinterface
