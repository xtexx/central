`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Branch Target Queue synchronous I/O interface
interface btq_addr_if
  import inst_pkg::*;
(
    input logic clk,
    input logic rst
);

  logic [31:0] hi32;
  logic valid;
  logic ready;

  modport tx(output hi32, output valid, input ready);
  modport rx(input hi32, input valid, output ready);

  `ASSERT_KNOWN(BTQHandshakeKnown, {valid, ready}, clk, rst);
  `ASSERT_KNOWN_IF(BTQDataKnown, hi32, valid, clk, rst);

endinterface
