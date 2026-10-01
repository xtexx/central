`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Physical register allocator interface
// Free list drives `preg` and `valid` using combinational logic.
// Free list pops `used` entries at clk posedge.
interface preg_alloc_if
  import inst_pkg::*;
#(
    parameter int unsigned BATCH_SIZE = 1
) (
    input logic clk,
    input logic rst
);

  parameter int unsigned NUM_W = cc_pkg::cnt_width(BATCH_SIZE);

  inst_pkg::phy_reg_t preg[BATCH_SIZE];
  logic [BATCH_SIZE-1:0] valid;
  logic [NUM_W-1:0] used;

  modport user(input preg, input valid, output used);
  modport list(output preg, output valid, input used);

  `ASSERT_KNOWN(PRegAllocKnown, {preg, valid, used}, clk, rst);

endinterface
