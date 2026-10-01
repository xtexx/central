`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/registers.svh"
`include "common_cells/assertions.svh"

// Physical Register File
// VReg 0 ($zero) is always mapped to PReg 0.
// Writes to PReg 0 are discarded.
module reg_file
  import inst_pkg::*;
#(
    parameter int unsigned DATA_W = 64,
    parameter int unsigned REG_N = 64,
    parameter int unsigned READ_PORTS = 1,
    parameter int unsigned WRITE_PORTS = 1,
    parameter int unsigned INIT_READY_REG_N = 32
) (
    input logic clk,
    input logic rst,

    prf_read_if.prf rd_if[READ_PORTS],
    prf_write_if.prf wr_if[WRITE_PORTS]
);

  // reg[DATA_W] = ready; reg[DATA_W-1:0] = data
  logic [DATA_W:0] mem[REG_N];

  // Extract write ports
  inst_pkg::phy_reg_t wr_preg[WRITE_PORTS];
  logic [63:0] wr_data[WRITE_PORTS];
  logic wr_valid[WRITE_PORTS];

  for (genvar i = 0; i < WRITE_PORTS; i++) begin : gen_wr_ports
    assign wr_preg[i]  = wr_if[i].preg;
    assign wr_data[i]  = wr_if[i].data;
    assign wr_valid[i] = wr_if[i].valid;
  end

  // Interface logic
  always_ff @(posedge clk) begin
    if (rst) begin
      // Reset logic
      for (int i = 0; i < REG_N; i++) begin
        mem[i] <= '0;
      end
      for (int i = 0; i < INIT_READY_REG_N; i++) begin
        mem[i][DATA_W] <= 1'b1;
      end
    end else begin
      // Write ports
      for (int i = 0; i < WRITE_PORTS; i++) begin
        if (wr_valid[i] && (wr_preg[i] != 0)) begin
          mem[wr_preg[i]] <= {1'b1, DATA_W'(wr_data[i])};
        end
      end
    end
  end

  for (genvar i = 0; i < READ_PORTS; i++) begin : gen_rd_ports
    assign rd_if[i].data  = mem[rd_if[i].preg][DATA_W-1:0];
    assign rd_if[i].ready = mem[rd_if[i].preg][DATA_W];
  end

endmodule
