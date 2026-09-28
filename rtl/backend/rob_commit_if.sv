`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Re-Order Buffer committer interface
interface rob_commit_if (
    input logic clk,
    input logic rst
);

  import inst_pkg::*;

  inst_pkg::rob_entry_t entry;
  logic valid;
  logic ready;

  modport committer(input entry, input valid, output ready);
  modport rob(output entry, output valid, input ready);

  `ASSERT_KNOWN_IF(ROBCommitKnown, entry, valid & ready, clk, rst);

endinterface
