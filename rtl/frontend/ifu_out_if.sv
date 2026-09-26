`timescale 1ns / 1ps
`default_nettype none

interface ifu_out_if #(
    parameter int unsigned ADDR_W = 40
) (
    input logic clk,
    input logic rst
);

  import ifu_pkg::*;

  ifu_pkg::ifu_out_resp_t resp;
  logic [31:0] inst;
  logic [ADDR_W-1:0] pc;
  logic valid;
  logic ready;

  modport tx(output resp, inst, pc, valid, input ready);
  modport rx(input resp, inst, pc, valid, output ready);

  a_data_known :
  assert property (@(posedge clk) disable iff (rst) (valid & ready) |-> !$isunknown(
      {resp, inst, pc}
  ));

endinterface
