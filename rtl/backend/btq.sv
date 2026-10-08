`timescale 1ns / 1ps
`default_nettype wire

// FIFO Branch Target Queue
module btq #(
    parameter int unsigned DEPTH = 2
) (
    input logic clk,
    input logic rst,
    btq_addr_if.rx rx,
    btq_addr_if.tx tx,
    input logic flush
);

  logic [cc_pkg::cnt_width(DEPTH)-1:0] unused_fifo_usage;

  if (DEPTH == 2) begin : gen_spill
    cc_spill_register_flushable #(
        .data_t(logic [31:0])
    ) fifo (
        .clk_i  (clk),
        .rst_ni ('1),
        .clr_i  (rst),
        .flush_i(flush),
        .valid_i(rx.valid && !flush),
        .ready_o(rx.ready),
        .data_i (rx.hi32),
        .valid_o(tx.valid),
        .ready_i(tx.ready),
        .data_o (tx.hi32)
    );
  end else begin : gen_fifo
    cc_stream_fifo #(
        .FallThrough(1),
        .Depth(DEPTH),
        .data_t(logic [31:0])
    ) fifo (
        .clk_i  (clk),
        .rst_ni ('1),
        .clr_i  (rst),
        .flush_i(flush),
        .usage_o(unused_fifo_usage),
        .data_i (rx.hi32),
        .valid_i(rx.valid && !flush),
        .ready_o(rx.ready),
        .data_o (tx.hi32),
        .valid_o(tx.valid),
        .ready_i(tx.ready)
    );
  end

endmodule
