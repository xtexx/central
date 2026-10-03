`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Interface for syncing RAT between committer and RRU
interface rat_sync_if
  import inst_pkg::*;
#(
    parameter int unsigned VREGS = 32
) (
    input logic clk,
    input logic rst
);

  inst_pkg::phy_reg_t pregs[32];
  logic valid;

  modport rx(input pregs, input valid);
  modport tx(output pregs, output valid);

  for (genvar i = 0; i < VREGS; i++) begin : gen_preg_assertions
    `ASSERT_KNOWN_IF(RATSyncRegKnown, pregs[i], valid, clk, rst);
  end

endinterface
