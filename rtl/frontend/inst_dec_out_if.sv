`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Instruction Decoder Unit output interface
interface inst_dec_out_if
  import inst_pkg::*;
(
    input logic clk,
    input logic rst
);

  inst_pkg::decoded_inst_t inst;
  logic valid;
  logic ready;

  modport tx(output inst, valid, input ready);
  modport rx(input inst, valid, output ready);

  `ASSERT_KNOWN_IF(IDUOutKnown, {inst, ready}, valid, clk, rst);

endinterface
