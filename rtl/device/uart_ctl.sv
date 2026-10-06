`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// UART TTL 8n1 serial controller
module uart_ctl
  import inst_pkg::*;
(
    input logic clk,
    input logic clk_io,
    input logic rst,

    AXI_LITE.Slave mmio,
    output logic uart_tx
);

  bit [3:0][15:0] cfg_freq_pat;

  logic tx_fifo_src_valid, tx_fifo_src_ready;

  // MMIO write interface
  logic [5:0] mmio_wr_addr;
  assign mmio_wr_addr = mmio.aw_addr[5:0];

  logic mmio_wr_tx_fifo, mmio_wr_freq_pat;
  assign mmio_wr_tx_fifo  = (mmio_wr_addr == 'h00) && mmio.w_strb[0];
  assign mmio_wr_freq_pat = (mmio_wr_addr == 'h08);

  logic mmio_wr;
  assign mmio_wr = mmio.aw_valid && mmio.w_valid
    && (!mmio.b_valid || mmio.b_ready)
    && !mmio.aw_ready && !mmio.w_ready
    && (!mmio_wr_tx_fifo || tx_fifo_src_ready);

  assign tx_fifo_src_valid = mmio_wr && mmio_wr_tx_fifo;

  always_ff @(posedge clk) begin
    if (rst) begin
      mmio.aw_ready <= '0;
      mmio.w_ready  <= '0;
      mmio.b_valid  <= '0;
      mmio.b_resp   <= '0;
    end else begin
      mmio.aw_ready <= mmio_wr;
      mmio.w_ready  <= mmio_wr;
      mmio.b_valid  <= (mmio.b_valid && !mmio.b_ready) || mmio_wr;
      if (mmio_wr) begin
        mmio.b_resp <= axi_pkg::RESP_DECERR;
        unique0 if (mmio_wr_freq_pat && |mmio.w_strb) begin
          mmio.b_resp  <= axi_pkg::RESP_OKAY;
          cfg_freq_pat <= mmio.w_data;
        end else if (mmio_wr_tx_fifo && mmio.w_strb[0]) begin
          mmio.b_resp <= axi_pkg::RESP_OKAY;
        end
      end
    end
  end

  // MMIO read interface
  logic [5:0] mmio_rd_addr;
  assign mmio_rd_addr = mmio.ar_addr[5:0];

  logic mmio_rd_freq_pat;
  assign mmio_rd_freq_pat = (mmio_rd_addr == 'h08);

  logic mmio_rd;
  assign mmio_rd = mmio.ar_valid && (!mmio.r_valid || mmio.r_ready) && !mmio.ar_ready;

  always_ff @(posedge clk) begin
    if (rst) begin
      mmio.ar_ready <= '0;
      mmio.r_valid  <= '0;
      mmio.r_resp   <= '0;
    end else begin
      mmio.ar_ready <= mmio_rd;
      mmio.r_valid  <= (mmio.r_valid && !mmio.r_ready) || mmio_rd;
      if (mmio_wr) begin
        mmio.r_resp <= axi_pkg::RESP_DECERR;
        mmio.r_data <= '0;
        unique0 if (mmio_rd_freq_pat) begin
          mmio.r_data <= cfg_freq_pat;
        end
      end
    end
  end

  // Shared frequency divider
  logic clk_uart;
  freq_div shared_freq_div (
      .clk_in(clk_io),
      .cfg_pattern({>>{cfg_freq_pat}}),
      .clk_out(clk_uart)
  );

  // Sender per-bit frequency divider, ratio = 16
  bit [3:0] tx_bit_clk_cnt;
  always_ff @(posedge clk_uart) tx_bit_clk_cnt <= tx_bit_clk_cnt + 1;
  logic clk_uart_tx_bit;
  assign clk_uart_tx_bit = tx_bit_clk_cnt[$bits(tx_bit_clk_cnt)-1];

  // Sender per-byte frequency divider, ratio = 16
  bit [3:0] tx_byte_clk_cnt;
  always_ff @(posedge clk_uart_tx_bit) tx_byte_clk_cnt <= tx_byte_clk_cnt + 1;
  logic clk_uart_tx_byte;
  assign clk_uart_tx_byte = !tx_byte_clk_cnt[$bits(tx_byte_clk_cnt)-1];
  logic posedge_uart_tx_byte;
  assign posedge_uart_tx_byte = tx_byte_clk_cnt == 0;

  // Sender CDC FIFO
  logic [7:0] tx_fifo_dst_data;
  logic tx_fifo_dst_valid, tx_fifo_dst_ready;
  cc_cdc_fifo_gray #(
      .Width(8),
      .LogDepth($clog2(8))
  ) tx_cdc (
      .src_rst_ni (!rst),
      .src_clk_i  (clk),
      .src_data_i (mmio.w_data[7:0]),
      .src_valid_i(tx_fifo_src_valid),
      .src_ready_o(tx_fifo_src_ready),

      .dst_rst_ni (!rst),
      .dst_clk_i  (clk_uart_tx_byte),
      .dst_data_o (tx_fifo_dst_data),
      .dst_valid_o(tx_fifo_dst_valid),
      .dst_ready_i(tx_fifo_dst_ready)
  );
  assign tx_fifo_dst_ready = posedge_uart_tx_byte;

  // Bits to be transmitted, including the head and tail bits
  bit [9:0] tx_data;

  // Sender
  always_ff @(posedge clk_uart_tx_bit) begin
    if (tx_fifo_dst_valid && tx_fifo_dst_ready) begin
`ifdef SIMULATION_VERILATOR
      $c("TYRO_TB_UART_PUTC(", tx_fifo_dst_data, ");");
`endif
      tx_data <= {1'b1, tx_fifo_dst_data, 1'b0};
    end else begin
      tx_data <= {1'b1, tx_data[9:1]};
    end
  end
  assign uart_tx = tx_data[0];

endmodule
