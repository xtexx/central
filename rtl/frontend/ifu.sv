`timescale 1ns / 1ps
`default_nettype wire

// Instruction Fetch Unit
module ifu
  import ifu_pkg::*;
(
    input logic clk,
    input logic rst,
    AXI_LITE.Master pmem,
    ifu_out_if.tx ifu_if,
    ftq_addr_if.rx ftq_if,
    input logic flush
);

  logic pc_valid, flush_abort;
  logic [pmem.AXI_ADDR_WIDTH-1:0] pc;

  initial assert (pmem.AXI_DATA_WIDTH == 64);

  always_comb begin
    pmem.ar_addr = pc;
    pmem.ar_prot = 3'b100;
    pmem.r_ready = '1;

    pmem.aw_valid = '0;
    pmem.w_valid = '0;
    pmem.b_ready = '1;

    ifu_if.pc = ifu_if.ADDR_W'(pc);

    ftq_if.ready = !pc_valid;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      pc_valid <= 0;
      ifu_if.valid <= 0;
      pmem.ar_valid <= 0;
      flush_abort <= 0;
    end else begin
      if (flush) flush_abort <= 1;
      // Receive PC from FTQ out & send PC beat to AXI AR
      if (ftq_if.valid && ftq_if.ready && !flush) begin
        pc <= pmem.AXI_ADDR_WIDTH'(ftq_if.addr);
        pc_valid <= 1;
        flush_abort <= 0;

        // Check PC alignment
        if (ftq_if.addr[1:0] != 0) begin
          ifu_if.resp  <= IFUOutMachErr;
          ifu_if.valid <= 1;
        end else begin
          pmem.ar_valid <= 1;
        end
      end
      // Complete PC beat on AXI AR
      if (pmem.ar_valid & pmem.ar_ready) begin
        pmem.ar_valid <= 0;
      end
      // Receive data beat from AXI R & send to IFU out
      if (pmem.r_valid & pmem.r_ready) begin
        assert (ifu_if.valid == 0);
        if (pmem.r_resp[1] == '0) begin
          ifu_if.resp <= IFUOutSuccess;
        end else begin
          ifu_if.resp <= IFUOutMachErr;
        end
        if (pc[2]) ifu_if.inst <= pmem.r_data[63:32];
        else ifu_if.inst <= pmem.r_data[31:0];
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
