`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Physical Register File synchronous writer interface
interface prf_write_if
  import inst_pkg::*;
(
    input logic clk,
    input logic rst
);

  inst_pkg::phy_reg_t preg;
  logic [63:0] data;
  logic valid;

  modport user(output preg, output data, output valid);
  modport prf(input preg, input data, input valid);

  `ASSERT_KNOWN_IF(PRFWriteKnown, {preg, data}, valid, clk, rst);

endinterface
