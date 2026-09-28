`timescale 1ns / 1ps
`default_nettype wire

// Register Renamer output interface
interface rr_out_if (
    input logic clk,
    input logic rst
);

  import ifu_pkg::*;

  ifu_pkg::ifu_out_resp_t resp;
  logic [31:0] inst;
  logic [63:0] pc;
  logic valid;
  logic ready;

  modport tx(output resp, inst, pc, valid, input ready);
  modport rx(input resp, inst, pc, valid, output ready);

  a_data_known :
  assert property (@(posedge clk) disable iff (rst) (valid & ready) |-> !$isunknown(
      {resp, inst, pc}
  ));

endinterface
