`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Re-Order Buffer execution interface
interface rob_execute_if (
    input logic clk,
    input logic rst
);

  import inst_pkg::*;

  inst_pkg::rob_idx_t idx;
  inst_pkg::inst_commit_type_t commit_type;
  inst_pkg::inst_commit_data_t data;
  logic valid;

  modport executor(output idx, output commit_type, output data, output valid);
  modport rob(input idx, input commit_type, input data, input valid);

  `ASSERT_KNOWN_IF(ROBExecuteKnown, {idx, commit_type, data}, valid, clk, rst);

endinterface
