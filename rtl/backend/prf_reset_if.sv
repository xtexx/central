`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Physical Register File synchronous register ready-bit reset interface
interface prf_reset_if
  import inst_pkg::*;
(
    input logic clk,
    input logic rst
);

  inst_pkg::phy_reg_t preg;
  logic valid;

  modport user(output preg, output valid);
  modport prf(input preg, input valid);

  `ASSERT_KNOWN_IF(PRFResetKnown, preg, valid, clk, rst);

endinterface
