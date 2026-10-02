`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Register Rename output interface, synchronous handshake
interface rr_out_if
  import inst_pkg::*;
(
    input logic clk,
    input logic rst
);

  inst_pkg::rr_inst_t inst;
  logic valid;
  logic ready;

  modport tx(output inst, valid, input ready);
  modport rx(input inst, valid, output ready);

  `ASSERT_KNOWN(RROutHandshakeKnown, {valid, ready}, clk, rst);
  `ASSERT_KNOWN_IF(RROutInstKnown, inst, valid && ready, clk, rst);

endinterface
