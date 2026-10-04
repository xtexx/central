`timescale 1ns / 1ps
`default_nettype wire

module top (
    input logic clk,
    input logic rst
);
  // Memory Controller
  taxi_axil_if #(
      .DATA_W(64),
      .ADDR_W(32)
  ) pmem_region_axil_if[1] ();
  taxi_axil_ram sram_mc (
      .clk(clk),
      .rst(rst),
      .s_axil_wr(pmem_region_axil_if[0]),
      .s_axil_rd(pmem_region_axil_if[0])
  );

`ifdef PRELD_FIRMWARE
  $readmemh("firmware/zig-out/tyro-core-firmware.hex", sram_mc.mem);
`endif

  // Memory Interconnect
  taxi_axil_if #(
      .DATA_W(64),
      .ADDR_W(40)
  ) pmem_axil_if[2] ();
  taxi_axil_interconnect #(
      .S_COUNT(2),
      .M_COUNT(1),
      .ADDR_W(40),
      .M_ADDR_W(32),
      .M_REGIONS(1),
      .M_BASE_ADDR({40'h0000000000})
  ) mem_interconnect (
      .clk(clk),
      .rst(rst),
      .s_axil_wr(pmem_axil_if),
      .s_axil_rd(pmem_axil_if),
      .m_axil_wr(pmem_region_axil_if),
      .m_axil_rd(pmem_region_axil_if)
  );

  // Cores
  tyro_core core (
      .clk(clk),
      .rst(rst),
      .pmem_wr(pmem_axil_if[0:1]),
      .pmem_rd(pmem_axil_if[0:1])
  );
endmodule
