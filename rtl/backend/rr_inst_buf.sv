`timescale 1ns / 1ps
`default_nettype wire

// FIFO RR-Instruction Buffer
module rr_inst_buf #(
    parameter int unsigned DEPTH = 2
) (
    input logic clk,
    input logic rst,
    rr_out_if.rx rx,
    rr_out_if.tx tx,
    input logic flush
);

  logic [cc_pkg::cnt_width(DEPTH)-1:0] unused_fifo_usage;

  if (DEPTH == 2) begin : gen_spill
    cc_spill_register_flushable #(
        .data_t(inst_pkg::rr_inst_t)
    ) fifo (
        .clk_i  (clk),
        .rst_ni ('1),
        .clr_i  (rst | flush),
        .flush_i('0),
        .valid_i(rx.valid),
        .ready_o(rx.ready),
        .data_i (rx.inst),
        .valid_o(tx.valid),
        .ready_i(tx.ready),
        .data_o (tx.inst)
    );
  end else begin : gen_fifo
    cc_stream_fifo #(
        .FallThrough(1),
        .Depth(DEPTH),
        .data_t(inst_pkg::rr_inst_t)
    ) fifo (
        .clk_i  (clk),
        .rst_ni ('1),
        .clr_i  ('0),
        .flush_i(rst | flush),
        .usage_o(unused_fifo_usage),
        .data_i (rx.inst),
        .valid_i(rx.valid),
        .ready_o(rx.ready),
        .data_o (tx.inst),
        .valid_o(tx.valid),
        .ready_i(tx.ready)
    );
  end

endmodule
