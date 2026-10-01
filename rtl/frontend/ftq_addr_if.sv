`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Fetch Target Queue address interface
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

  `ASSERT_KNOWN_IF(FTQAddrKnown, addr, valid && ready, clk, rst);

endinterface
