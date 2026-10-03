`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Re-Order Buffer combinational PC reader interface
interface rob_pc_read_if (
    input logic clk,
    input logic rst
);

  inst_pkg::rob_idx_t idx;
  logic [63:0] pc;

  modport user(output idx, input pc);
  modport rob(input idx, output pc);

  `ASSERT_KNOWN(ROBPCReadKnown, {idx, pc}, clk, rst);

endinterface
