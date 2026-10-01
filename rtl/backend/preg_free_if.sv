`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Physical register synchronous free interface
interface preg_free_if
  import inst_pkg::*;
#(
    parameter int unsigned BATCH_SIZE = 1
) (
    input logic clk,
    input logic rst
);

  inst_pkg::phy_reg_t preg[BATCH_SIZE];
  logic [BATCH_SIZE-1:0] valid;

  modport user(output preg, output valid);
  modport list(input preg, input valid);

  `ASSERT_KNOWN(PRegFreeKnown, {preg, valid}, clk, rst);

endinterface
