`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Physical Register File reader interface
interface prf_read_if
  import inst_pkg::*;
(
    input logic clk,
    input logic rst
);

  inst_pkg::phy_reg_t preg;
  logic [63:0] data;
  logic ready;

  modport writer(output preg, input data, input ready);
  modport prf(input preg, output data, output ready);

  `ASSERT_KNOWN(PRFReadReqKnown, {preg, ready}, clk, rst);
  `ASSERT_KNOWN_IF(PRFReadRespKnown, data, valid & ready, clk, rst);

endinterface
