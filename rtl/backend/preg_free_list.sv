`timescale 1ns / 1ps
`default_nettype wire

`include "common_cells/assertions.svh"

module preg_free_list
  import inst_pkg::*;
#(
    parameter int unsigned DEPTH = 32,
    parameter int unsigned FIRST_FREE_REG = 32
) (
    input logic clk,
    input logic rst,

    preg_alloc_if.list alloc_if,
    preg_free_if.list  free_if
);

  localparam int unsigned PtrW = cc_pkg::idx_width(DEPTH);

  inst_pkg::phy_reg_t [DEPTH-1:0] list_q, list_d;
  logic [PtrW:0] rptr_q, rptr_d;
  logic [PtrW:0] wptr_q, wptr_d;

  // Flip-flop
  always_ff @(posedge clk) begin
    if (rst) begin
      list_q <= '0;
      for (int i = 0; i < DEPTH; i++) begin
        list_q[i] <= ($bits(inst_pkg::phy_reg_t))'(FIRST_FREE_REG + i);
      end
      rptr_q <= '0;
      wptr_q <= {1'b1, PtrW'(0)};
    end else begin
      list_q <= list_d;
      rptr_q <= rptr_d;
      wptr_q <= wptr_d;
    end
  end

  logic is_empty  /*verilator public_flat_rd*/;
  logic is_full  /*verilator public_flat_rd*/;
  assign is_empty = wptr_q == rptr_q;
  assign is_full  = (wptr_q[PtrW-1:0] == rptr_q[PtrW-1:0]) && (wptr_q[PtrW] != rptr_q[PtrW]);

  always_comb begin
    // Default assignments
    list_d = list_q;
    rptr_d = rptr_q;
    wptr_d = wptr_q;

    // Allocator interface
    rptr_d = rptr_d + (PtrW + 1)'(alloc_if.used);

    alloc_if.valid = '0;
    for (int i = 0; i < alloc_if.BATCH_SIZE; i++) begin
      alloc_if.preg[i]  = list_q[(rptr_q[PtrW-1:0]+(PtrW'(i)))];
      alloc_if.valid[i] = ((rptr_q + (PtrW + 1)'(i)) != wptr_q);
      if (i != 0) begin
        alloc_if.valid[i] = alloc_if.valid[i] & alloc_if.valid[i-1];
      end
    end

    // Free interface
    for (int i = 0; i < free_if.BATCH_SIZE; i++) begin
      if (free_if.valid[i]) begin
        list_d[wptr_d[PtrW-1:0]] = free_if.preg[i];
        wptr_d = wptr_d + 1;
        assert (wptr_d != rptr_q);
      end
    end
  end

  `ASSERT_INIT(CheckDepthPow2, cc_pkg::is_power_of_2(DEPTH));

endmodule
