`timescale 1ns / 1ps
`default_nettype wire

interface sram_if #(
    parameter int ADDR_WIDTH   = 16,
    parameter int DATA_WIDTH   = 32,
    parameter int STRB_WIDTH   = (DATA_WIDTH + 7) / 8,
    parameter int READ_LATENCY = 1
) (
    input logic clk,
    input logic rst
);

  logic                  cs_n;
  logic                  we_n;
  logic                  re_n;
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] wdata;
  logic [DATA_WIDTH-1:0] rdata;
  logic [STRB_WIDTH-1:0] be;

  modport master(output cs_n, we_n, re_n, addr, wdata, be, input rdata, input clk, rst);

  modport slave(input cs_n, we_n, re_n, addr, wdata, be, output rdata, input clk, rst);

  modport monitor(input cs_n, we_n, re_n, addr, wdata, be, rdata, input clk, rst);

  a_addr_known :
  assert property (@(posedge clk) disable iff (rst) (!cs_n) |-> !$isunknown(addr));

  a_wdata_known :
  assert property (@(posedge clk) disable iff (rst) (!cs_n && !we_n) |-> !$isunknown({wdata, be}));

  a_rdata_known :
  assert property (@(posedge clk) disable iff (rst) (!cs_n && we_n && !re_n) |->
    ##READ_LATENCY !$isunknown(
      rdata
  ));

endinterface
