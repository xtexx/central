`timescale 1ns / 1ps
`default_nettype wire

// Instruction Fetch Unit
module ifu
  import ifu_pkg::*;
(
    input logic clk,
    input logic rst,
    taxi_axil_if.rd_mst pmem_rd,
    ifu_out_if.tx ifu_if,
    ftq_addr_if.rx ftq_if,
    input logic flush
);

  logic pc_valid, flush_abort;
  logic [pmem_rd.ADDR_W-1:0] pc;

  initial assert (pmem_rd.DATA_W == 64);

  always_comb begin
    pmem_rd.araddr = pc;
    pmem_rd.arprot = 3'b100;
    pmem_rd.aruser = '0;
    pmem_rd.rready = '1;

    ifu_if.pc = ifu_if.ADDR_W'(pc);

    ftq_if.ready = !pc_valid;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      pc_valid <= 0;
      ifu_if.valid <= 0;
      pmem_rd.arvalid <= 0;
      flush_abort <= 0;
    end else begin
      if (flush) flush_abort <= 1;
      // Receive PC from FTQ out & send PC beat to AXI AR
      if (ftq_if.valid && ftq_if.ready && !flush) begin
        pc <= pmem_rd.ADDR_W'(ftq_if.addr);
        pc_valid <= 1;
        flush_abort <= 0;

        // Check PC alignment
        if (ftq_if.addr[1:0] != 0) begin
          ifu_if.resp  <= IFUOutMachErr;
          ifu_if.valid <= 1;
        end else begin
          pmem_rd.arvalid <= 1;
        end
      end
      // Complete PC beat on AXI AR
      if (pmem_rd.arvalid & pmem_rd.arready) begin
        pmem_rd.arvalid <= 0;
      end
      // Receive data beat from AXI R & send to IFU out
      if (pmem_rd.rvalid & pmem_rd.rready) begin
        assert (ifu_if.valid == 0);
        if (pmem_rd.rresp[1] == '0) begin
          ifu_if.resp <= IFUOutSuccess;
        end else begin
          ifu_if.resp <= IFUOutMachErr;
        end
        if (pc[2]) ifu_if.inst <= pmem_rd.rdata[63:32];
        else ifu_if.inst <= pmem_rd.rdata[31:0];
        if (!(flush_abort || flush)) begin
          ifu_if.valid <= 1;
        end else begin
          ifu_if.valid <= 0;
          pc_valid <= 0;
        end
      end
      // Complete IFU out beat
      if (ifu_if.valid & ifu_if.ready) begin
        ifu_if.valid <= 0;
        pc_valid <= 0;
      end
    end
  end

endmodule
