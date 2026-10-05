`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

// SRAM Memory Controller
module sram #(
    parameter int unsigned ADDR_W = 16,
`ifndef PRELD_FIRMWARE
    /* verilator lint_off UNUSEDPARAM */
`endif
    parameter string FIRMWARE_PATH
`ifndef PRELD_FIRMWARE
    /* verilator lint_on UNUSEDPARAM */
`endif
) (
    input logic clk,
    input logic rst,
    AXI_LITE.Slave axil
);

  parameter int unsigned DATA_W = axil.AXI_DATA_WIDTH;
  parameter int unsigned STRB_W = axil.AXI_STRB_WIDTH;
  parameter int unsigned VALID_ADDR_W = ADDR_W - $clog2(STRB_W);

  (* ram_style = "block", syn_ramstyle = "block_ram" *)
  logic [DATA_W-1:0] mem[2**VALID_ADDR_W];

  initial begin
`ifdef PRELD_FIRMWARE
    $readmemh(FIRMWARE_PATH, mem);
`endif
  end

  logic [VALID_ADDR_W-1:0] aw_addr_valid;
  assign aw_addr_valid = VALID_ADDR_W'(axil.aw_addr >> (ADDR_W - VALID_ADDR_W));
  logic [VALID_ADDR_W-1:0] ar_addr_valid;
  assign ar_addr_valid = VALID_ADDR_W'(axil.ar_addr >> (ADDR_W - VALID_ADDR_W));

  // Write logic
  logic mem_wr;
  assign mem_wr = axil.aw_valid && axil.w_valid && (!axil.b_valid || axil.b_ready)
      && !axil.aw_ready && !axil.w_ready;

  assign axil.b_resp = 2'b00;

  always_ff @(posedge clk) begin
    if (rst) begin
      axil.aw_ready <= '0;
      axil.w_ready  <= '0;
      axil.b_valid  <= '0;
    end else begin
      axil.aw_ready <= mem_wr;
      axil.w_ready  <= mem_wr;
      axil.b_valid  <= (axil.b_valid && !axil.b_ready) || mem_wr;
      if (mem_wr) begin
        for (int i = 0; i < STRB_W; i = i + 1) begin
          if (axil.w_strb[i]) begin
            mem[aw_addr_valid][8*i+:8] <= axil.w_data[8*i+:8];
          end
        end
      end
    end
  end

  // Read logic
  logic mem_rd;
  assign mem_rd = axil.ar_valid && (!axil.r_valid || axil.r_ready) && !axil.ar_ready;

  assign axil.r_resp = 2'b00;

  always_ff @(posedge clk) begin
    if (rst) begin
      axil.ar_ready <= '0;
      axil.r_valid  <= '0;
    end else begin
      axil.ar_ready <= mem_rd;
      axil.r_valid  <= (axil.r_valid && !axil.r_ready) || mem_rd;
      if (mem_rd) begin
        axil.r_data <= mem[ar_addr_valid];
      end
    end
  end

endmodule
