`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Re-Order Buffer entry allocation interface
interface rob_alloc_if (
    input logic clk,
    input logic rst
);

  import inst_pkg::*;

  logic [63:0] pc;
  inst_pkg::rob_rr_entry_t rr[inst_pkg::ROB_ENTRY_REGS];
  logic valid;
  logic ready;
  inst_pkg::rob_idx_t idx;

  modport requester(output pc, output rr, output valid, input ready, input idx);
  modport rob(input pc, input rr, input valid, output ready, output idx);

  `ASSERT_KNOWN_IF(ROBAllocKnown, {pc, rr, idx}, valid & ready, clk, rst);

endinterface
