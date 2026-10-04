`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Load Store Queue synchronous I/O interface
interface lsq_if
  import inst_pkg::*;
(
    input logic clk,
    input logic rst
);

  inst_pkg::lsq_entry_t entry;
  logic valid;
  logic ready;

  modport tx(output entry, output valid, input ready);
  modport rx(input entry, input valid, output ready);

  `ASSERT_KNOWN(LSQHandshakeKnown, {valid, ready}, clk, rst);
  `ASSERT_KNOWN_IF(LSQDataKnown, entry, valid, clk, rst);

endinterface
