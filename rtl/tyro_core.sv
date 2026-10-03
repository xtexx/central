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
  // [0] -> ALU Exec
  // [1] -> CTL Exec
  rob_execute_if rob_exec[2] (
      .clk(clk),
      .rst(rst)
  );
  rob #(
      .DEPTH(8),
      .EXEC_PORTS(2)
  ) rob (
      .clk(clk),
      .rst(rst),
      .alloc_if(rob_alloc),
      .commit_if(rob_commit),
      .exec_if(rob_exec)
  );

  // Integer PRF
  // [0] [1] -> ALU Exec
  prf_read_if prf_rd[2] (
      .clk(clk),
      .rst(rst)
  );
  // [0] -> ALU Exec
  prf_write_if prf_wr[1] (
      .clk(clk),
      .rst(rst)
  );
  prf_reset_if prf_rst[2] (
      .clk(clk),
      .rst(rst)
  );
  reg_file #(
      .DATA_W(64),
      .REG_N(64),
      .READ_PORTS(2),
      .WRITE_PORTS(1),
      .RESET_PORTS(2)
  ) int_prf (
      .clk(clk),
      .rst(rst),
      .rd_if(prf_rd),
      .wr_if(prf_wr),
      .rst_if(prf_rst)
  );

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
      .prf_rst_if(prf_rst),
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

  // ALU Executor
  alu_exec alu_ex (
      .clk(clk),
      .rst(rst),
      .in(alu_dq_out),
      .prf_rd(prf_rd[0:1]),
      .prf_wr(prf_wr[0]),
      .rob_ex(rob_exec[0])
  );

  // CTL Dispatch Queue
  rr_out_if ctl_dq_out (
      .clk(clk),
      .rst(rst)
  );
  rr_inst_buf #(
      .DEPTH(2)
  ) ctl_dq (
      .clk(clk),
      .rst(rst),
      .rx(dp_o_ctl),
      .tx(ctl_dq_out),
      .flush(pipeline_flush)
  );

  // ALU Executor
  ctl_exec ctl_ex (
      .clk(clk),
      .rst(rst),
      .in(ctl_dq_out),
      .rob_ex(rob_exec[1])
  );

  // Committer
  committer #(
      .VREGS(32)
  ) committer (
      .clk(clk),
      .rst(rst),
      .rob_co(rob_commit),
      .free_list_free(free_list_free)
  );

endmodule
