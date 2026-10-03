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

  assign rob_commit.ready  = '0;
  assign rob_exec[0].valid = '0;

  // Integer PRF
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
      .clk  (clk),
      .rst  (rst),
      .rd_if(prf_rd),
      .wr_if(prf_wr)
  );

  assign prf_rd[0].preg  = 0;
  assign prf_wr[0].valid = '0;

  // Integer register free list
  preg_alloc_if #(
      .BATCH_SIZE(2)
  ) free_list_alloc (
      .clk(clk),
      .rst(rst)
  );
  preg_free_if #(
      .BATCH_SIZE(2)
  ) free_list_free (
      .clk(clk),
      .rst(rst)
  );
  preg_free_list free_list (
      .clk(clk),
      .rst(rst),
      .alloc_if(free_list_alloc),
      .free_if(free_list_free)
  );

  assign free_list_free.valid = 2'b00;

  // Register rename
  rr_out_if rr_out (
      .clk(clk),
      .rst(rst)
  );
  register_renamer #(
      .VREGS(32)
  ) rr (
      .clk(clk),
      .rst(rst),
      .idu_if(inst_dec_out),
      .free_list_if(free_list_alloc),
      .rob_if(rob_alloc),
      .out_if(rr_out)
  );

  // Instruction Dispatcher
  rr_out_if
      dp_o_alu (
          .clk(clk),
          .rst(rst)
      ),
      dp_o_ctl (
          .clk(clk),
          .rst(rst)
      );
  inst_dispatcher inst_dp (
      .in(rr_out),
      .o_alu(dp_o_alu),
      .o_ctl(dp_o_ctl)
  );

  assign dp_o_ctl.ready = 1;

  // ALU Dispatch Queue
  rr_out_if alu_dq_out (
      .clk(clk),
      .rst(rst)
  );
  rr_inst_buf #(
      .DEPTH(2)
  ) alu_dq (
      .clk(clk),
      .rst(rst),
      .rx(dp_o_alu),
      .tx(alu_dq_out),
      .flush(pipeline_flush)
  );

  assign alu_dq_out.ready = 1;

endmodule
