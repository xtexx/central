`timescale 1ns / 1ps
`default_nettype wire

module top (
    input  logic clk,
    input  logic rst,
    input  logic clk_io_ref,  // IO reference clock
    output logic uart_tx
);
  // Memory Topology
  typedef struct packed {
    int unsigned idx;
    logic [39:0] start_addr;
    logic [38:0] end_addr;
  } xbar_rule_40_t;

  localparam axi_pkg::xbar_cfg_t XBarCfg = '{
      NoSlvPorts        : 2,
      NoMstPorts        : 2,
      MaxMstTrans       : 2,
      MaxSlvTrans       : 2,
      FallThrough       : 1'b0,
      LatencyMode       : axi_pkg::CUT_ALL_AX,
      PipelineStages    : 0,
      AxiAddrWidth      : 40,
      AxiDataWidth      : 64,
      NoAddrRules       : 2,
      default: '0
  };

  // [0] -> SRAM MC
  // [1] -> UART 0
  AXI_LITE #(
      .AXI_DATA_WIDTH(64),
      .AXI_ADDR_WIDTH(40)
  ) pmem_region_axil_if[XBarCfg.NoMstPorts-1:0] ();

  localparam xbar_rule_40_t [XBarCfg.NoAddrRules-1:0] XBarAddrMap = '{
      '{idx: 0, start_addr: 'h0000000000, end_addr: 'h0000010000},
      '{idx: 1, start_addr: 'h0000100000, end_addr: 'h0000100040}
  };

  // Memory Controller
  sram #(
      .ADDR_W(16),
      .FIRMWARE_PATH("firmware/zig-out/tyro-firmware.hex")
  ) sram_mc (
      .clk (clk),
      .rst (rst),
      .axil(pmem_region_axil_if[0])
  );

  // UART Controller
  uart_ctl uart0 (
      .clk(clk),
      .clk_io(clk_io_ref),
      .rst(rst),
      .mmio(pmem_region_axil_if[1]),
      .uart_tx(uart_tx)
  );

  // Memory Interconnect
  AXI_LITE #(
      .AXI_DATA_WIDTH(64),
      .AXI_ADDR_WIDTH(40)
  ) pmem_axil_if[2] ();
  axi_lite_xbar_intf #(
      .Cfg(XBarCfg),
      .rule_t(xbar_rule_40_t)
  ) mem_xbar (
      .clk_i(clk),
      .rst_ni(!rst),
      .slv_ports(pmem_axil_if),
      .mst_ports(pmem_region_axil_if),
      .addr_map_i(XBarAddrMap),
      .en_default_mst_port_i('0),
      .default_mst_port_i('0)
  );

  // Cores
  tyro_core core (
      .clk (clk),
      .rst (rst),
      .pmem(pmem_axil_if[0:1])
  );
endmodule
