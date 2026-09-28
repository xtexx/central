`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// Physical Register File allocator interface
interface prf_alloc_if
  import inst_pkg::*;
(
    input logic clk,
    input logic rst
);

  inst_pkg::phy_reg_t preg;
  logic valid;
  logic ready;

  modport requester(input preg, input valid, output ready);
  modport prf(output preg, output valid, input ready);

  `ASSERT_KNOWN_IF(PRFAllocKnown, preg, valid & ready, clk, rst);

endinterface
