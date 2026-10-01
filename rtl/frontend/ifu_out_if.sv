`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Instruction Fetch Unit output interface
interface ifu_out_if
  import ifu_pkg::*;
#(
    parameter int unsigned ADDR_W = 40
) (
    input logic clk,
    input logic rst
);

  ifu_pkg::ifu_out_resp_t resp;
  logic [31:0] inst;
  logic [ADDR_W-1:0] pc;
  logic valid;
  logic ready;

  modport tx(output resp, inst, pc, valid, input ready);
  modport rx(input resp, inst, pc, valid, output ready);

  `ASSERT_KNOWN_IF(FTQOutKnown, {resp, inst, pc}, valid && ready, clk, rst);

endinterface
