`timescale 1ns / 1ps
`default_nettype wire

// FIFO Instruction Buffer
module inst_buf
  import ifu_pkg::*;
#(
    parameter int unsigned DEPTH = 4
) (
    input logic clk,
    input logic rst,
    ifu_out_if.rx rx,
    ifu_out_if.tx tx,
    input logic flush
);

  parameter int unsigned ADDR_W = rx.ADDR_W;
  initial assert (rx.ADDR_W == tx.ADDR_W);

  typedef struct packed {
    ifu_out_resp_t resp;
    logic [31:0] inst;
    logic [ADDR_W-1:0] pc;
  } inst_buf_entry_t;

  inst_buf_entry_t ifu_out;
  assign ifu_out.resp = rx.resp;
  assign ifu_out.inst = rx.inst;
  assign ifu_out.pc   = rx.pc;

  inst_buf_entry_t buf_out;
  assign tx.resp = buf_out.resp;
  assign tx.inst = buf_out.inst;
  assign tx.pc   = buf_out.pc;

  logic [cc_pkg::cnt_width(DEPTH)-1:0] fifo_usage;

  logic rst_ni, clr_i;

  cc_stream_fifo #(
      .FallThrough(1),
      .Depth(DEPTH),
      .data_t(inst_buf_entry_t)
  ) fifo (
      .clk_i  (clk),
      .rst_ni (rst_ni),
      .clr_i  (clr_i),
      .flush_i(rst | flush),
      .usage_o(fifo_usage),
      .data_i (ifu_out),
      .valid_i(rx.valid),
      .ready_o(rx.ready),
      .data_o (buf_out),
      .valid_o(tx.valid),
      .ready_i(tx.ready)
  );

endmodule
