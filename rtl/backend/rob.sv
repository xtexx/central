`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/registers.svh"
`include "common_cells/assertions.svh"

module rob
  import inst_pkg::*;
#(
    parameter int unsigned DEPTH = 8,
    parameter int unsigned EXEC_PORTS = 1
) (
    input logic clk,
    input logic rst,

    rob_alloc_if.rob   alloc_if,
    rob_commit_if.rob  commit_if,
    rob_execute_if.rob exec_if  [EXEC_PORTS]
);

  parameter int unsigned ADDR_W = cc_pkg::idx_width(DEPTH);

  inst_pkg::rob_entry_t [DEPTH-1:0] mem_q, mem_d;
  // r/wptr[ADDR_W] = generation; r/wptr[ADDR_W-1:0] = ROB index
  logic [ADDR_W:0] rptr_q, rptr_d;
  logic [ADDR_W:0] wptr_q, wptr_d;

  // Flip-Flop
  always_ff @(posedge (clk)) begin
    if (rst) begin
      rptr_q <= '0;
      wptr_q <= '0;
    end else begin
      mem_q  <= mem_d;
      rptr_q <= rptr_d;
      wptr_q <= wptr_d;
    end
  end

  // Capacity signals
  logic is_empty  /*verilator public_flat_rd*/;
  logic is_full  /*verilator public_flat_rd*/;
  assign is_empty = wptr_q == rptr_q;
  assign is_full = (wptr_q[ADDR_W-1:0] == rptr_q[ADDR_W-1:0]) && (wptr_q[ADDR_W] != rptr_q[ADDR_W]);

  // Executor write ports
  inst_pkg::rob_idx_t [EXEC_PORTS-1:0] exec_idx;
  inst_pkg::inst_commit_type_t [EXEC_PORTS-1:0] exec_commit_type;
  inst_pkg::inst_commit_data_t [EXEC_PORTS-1:0] exec_data;
  logic [EXEC_PORTS-1:0] exec_valid;

  for (genvar i = 0; i < EXEC_PORTS; i++) begin : gen_exec_ports
    assign exec_idx[i]         = exec_if[i].idx;
    assign exec_commit_type[i] = exec_if[i].commit_type;
    assign exec_data[i]        = exec_if[i].data;
    assign exec_valid[i]       = exec_if[i].valid;
  end

  always_comb begin
    // Default assignments
    mem_d = mem_q;
    rptr_d = rptr_q;
    wptr_d = wptr_q;

    // Allocator interface
    alloc_if.ready = !is_full;
    alloc_if.idx = wptr_q[ADDR_W-1:0];
    if (alloc_if.valid && alloc_if.ready) begin
      mem_d[wptr_q[ADDR_W-1:0]] = '0;
      mem_d[wptr_q[ADDR_W-1:0]].pc = alloc_if.pc;
      for (int i = 0; i < inst_pkg::ROB_ENTRY_REGS; i++) begin
        mem_d[wptr_q[ADDR_W-1:0]].rr[i] = alloc_if.rr[i];
      end
      wptr_d = wptr_q + 1;
    end

    // Committer interface
    commit_if.entry = mem_d[rptr_q[ADDR_W-1:0]];
    commit_if.valid = !is_empty && commit_if.entry.ready;
    if (commit_if.valid && commit_if.ready) begin
      rptr_d = rptr_q + 1;
    end

    // Executor write interface
    for (int i = 0; i < EXEC_PORTS; i++) begin
      if (exec_valid[i]) begin
        mem_d[exec_idx[i]].ready = 1;
        mem_d[exec_idx[i]].commit_type = exec_commit_type[i];
        mem_d[exec_idx[i]].commit_data = exec_data[i];
      end
    end
  end

  `ASSERT_INIT(CheckDepthPow2, cc_pkg::is_power_of_2(DEPTH));

endmodule
