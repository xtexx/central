`timescale 1ns / 1ps
`default_nettype wire

module tyro_core (
    input wire clk,
    input wire rst,
    taxi_axil_if.wr_mst pmem_wr,
    taxi_axil_if.rd_mst pmem_rd
);

  // parameter int unsigned PADDR_W = pmem_rd.ADDR_W;
  parameter int unsigned VADDR_W = 40;

  logic pipeline_flush = 0;

  // FTQ
  ftq_addr_if #(.ADDR_W(VADDR_W))
      ftq_out (
          .clk(clk),
          .rst(rst)
      ),
      ftq_redir (
          .clk(clk),
          .rst(rst)
      );
  seq_pc_gen seq_pc_gen (
      .clk(clk),
      .rst(rst),
      .out_if(ftq_out),
      .redir_if(ftq_redir)
  );
  assign ftq_redir.valid = 0;

  // IFU
  ifu_out_if #(.ADDR_W(VADDR_W))
      ifu_out (
          .clk(clk),
          .rst(rst)
      ),
      inst_buf_out (
          .clk(clk),
          .rst(rst)
      );
  ifu ifu (
      .clk(clk),
      .rst(rst),
      .pmem_rd(pmem_rd),
      .ifu_if(ifu_out),
      .ftq_if(ftq_out)
  );

  // InstBuf
  inst_buf #(
      .DEPTH(4)
  ) inst_buf (
      .clk(clk),
      .rst(rst),
      .rx(ifu_out),
      .tx(inst_buf_out),
      .flush(pipeline_flush)
  );

  // Decoder
  inst_dec_out_if inst_dec_out (
      .clk(clk),
      .rst(rst)
  );
  inst_decoder idu (
      .rst(rst),
      .in (inst_buf_out),
      .out(inst_dec_out)
  );

  assign inst_dec_out.ready = 1;

  // ROB
  rob_alloc_if rob_alloc (
      .clk(clk),
      .rst(rst)
  );
  rob_commit_if rob_commit (
      .clk(clk),
      .rst(rst)
  );
  rob_execute_if rob_exec[1] (
      .clk(clk),
      .rst(rst)
  );
  rob #(
      .DEPTH(8),
      .EXEC_PORTS(1)
  ) rob (
      .clk(clk),
      .rst(rst),
      .alloc_if(rob_alloc),
      .commit_if(rob_commit),
      .exec_if(rob_exec)
  );

  assign rob_alloc.ready   = '0;
  assign rob_commit.ready  = '0;
  assign rob_exec[0].valid = '0;

  // Integer PRF
  prf_alloc_if prf_alloc (
      .clk(clk),
      .rst(rst)
  );
  prf_read_if prf_rd[1] (
      .clk(clk),
      .rst(rst)
  );
  prf_write_if prf_wr[1] (
      .clk(clk),
      .rst(rst)
  );
  reg_file #(
      .DATA_W(64),
      .REG_N(64),
      .READ_PORTS(1),
      .WRITE_PORTS(1)
  ) int_prf (
      .clk(clk),
      .rst(rst),
      .alloc_if(prf_alloc),
      .rd_if(prf_rd),
      .wr_if(prf_wr)
  );

  assign prf_alloc.valid = '0;
  assign prf_rd[0].preg = 0;
  assign prf_wr[0].valid = '0;

endmodule
