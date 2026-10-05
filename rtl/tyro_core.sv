`timescale 1ns / 1ps
`default_nettype wire

module tyro_core (
    input wire clk,
    input wire rst,
    // [0] -> Committer
    // [1] -> IFU
    AXI_LITE.Master pmem[2]
);

  // parameter int unsigned PADDR_W = pmem_rd.ADDR_W;
  parameter int unsigned VADDR_W = 40;

  logic flush_pipeline;

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
      .pmem(pmem[1]),
      .ifu_if(ifu_out),
      .ftq_if(ftq_out),
      .flush(flush_pipeline)
  );

  // InstBuf
  inst_buf #(
      .DEPTH(4)
  ) inst_buf (
      .clk(clk),
      .rst(rst),
      .rx(ifu_out),
      .tx(inst_buf_out),
      .flush(flush_pipeline)
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
  // [2] -> BRU Exec
  // [3] -> AGU Exec
  rob_execute_if rob_exec[4] (
      .clk(clk),
      .rst(rst)
  );
  // [0] -> BRU Exec
  rob_pc_read_if rob_pc_rd[1] (
      .clk(clk),
      .rst(rst)
  );
  rob #(
      .DEPTH(8),
      .EXEC_PORTS(4),
      .PC_READ_PORTS(1)
  ) rob (
      .clk(clk),
      .rst(rst),
      .flush(flush_pipeline),
      .alloc_if(rob_alloc),
      .commit_if(rob_commit),
      .exec_if(rob_exec),
      .pc_rd_if(rob_pc_rd)
  );

  // Integer PRF
  // [0] [1] -> ALU Exec
  // [2] [3] -> BRU Exec
  // [4] [5] [6] -> AGU Exec
  prf_read_if prf_rd[7] (
      .clk(clk),
      .rst(rst)
  );
  // [0] -> ALU Exec
  // [1] -> BRU Exec
  // [2] -> Committer
  prf_write_if prf_wr[3] (
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
      .READ_PORTS(7),
      .WRITE_PORTS(3),
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
      .BATCH_SIZE(3)
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
  rat_sync_if #(
      .VREGS(32)
  ) rat_sync (
      .clk(clk),
      .rst(rst)
  );
  logic rr_idle;
  register_renamer #(
      .VREGS(32)
  ) rr (
      .clk(clk),
      .rst(rst),
      .flush(flush_pipeline),
      .idu_if(inst_dec_out),
      .free_list_if(free_list_alloc),
      .prf_rst_if(prf_rst),
      .rob_if(rob_alloc),
      .out_if(rr_out),
      .rat_sync(rat_sync),
      .rr_idle(rr_idle)
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
      ),
      dp_o_bru (
          .clk(clk),
          .rst(rst)
      ),
      dp_o_agu (
          .clk(clk),
          .rst(rst)
      );
  inst_dispatcher inst_dp (
      .in(rr_out),
      .o_alu(dp_o_alu),
      .o_ctl(dp_o_ctl),
      .o_bru(dp_o_bru),
      .o_agu(dp_o_agu)
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
      .flush(flush_pipeline)
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
      .flush(flush_pipeline)
  );

  // CTL Executor
  ctl_exec ctl_ex (
      .clk(clk),
      .rst(rst),
      .in(ctl_dq_out),
      .rob_ex(rob_exec[1])
  );

  // BRU Dispatch Queue
  rr_out_if bru_dq_out (
      .clk(clk),
      .rst(rst)
  );
  rr_inst_buf #(
      .DEPTH(2)
  ) bru_dq (
      .clk(clk),
      .rst(rst),
      .rx(dp_o_bru),
      .tx(bru_dq_out),
      .flush(flush_pipeline)
  );

  // Branch Target Queue
  btq_addr_if
      btq_push (
          .clk(clk),
          .rst(rst)
      ),
      btq_pop (
          .clk(clk),
          .rst(rst)
      );
  btq #(
      .DEPTH(2)
  ) btq (
      .clk(clk),
      .rst(rst),
      .rx(btq_push),
      .tx(btq_pop),
      .flush(flush_pipeline)
  );

  // BRU Executor
  bru_exec bru_ex (
      .clk(clk),
      .rst(rst),
      .in(bru_dq_out),
      .prf_rd(prf_rd[2:3]),
      .prf_wr(prf_wr[1]),
      .rob_pc_rd(rob_pc_rd[0]),
      .rob_ex(rob_exec[2]),
      .btq_push(btq_push)
  );

  // Load/Store Queue
  lsq_if
      lsq_push (
          .clk(clk),
          .rst(rst)
      ),
      lsq_pop (
          .clk(clk),
          .rst(rst)
      );
  lsq #(
      .DEPTH(2)
  ) lsq (
      .clk(clk),
      .rst(rst),
      .rx(lsq_push),
      .tx(lsq_pop),
      .flush(flush_pipeline)
  );

  // AGU Dispatch Queue
  rr_out_if agu_dq_out (
      .clk(clk),
      .rst(rst)
  );
  rr_inst_buf #(
      .DEPTH(2)
  ) agu_dq (
      .clk(clk),
      .rst(rst),
      .rx(dp_o_agu),
      .tx(agu_dq_out),
      .flush(flush_pipeline)
  );

  // AGU
  agu_exec agu_ex (
      .clk(clk),
      .rst(rst),
      .in(agu_dq_out),
      .prf_rd(prf_rd[4:6]),
      .rob_ex(rob_exec[3]),
      .lsq_push(lsq_push)
  );

  // Committer
  committer #(
      .VREGS(32)
  ) committer (
      .clk(clk),
      .rst(rst),
      .rob_co(rob_commit),
      .preg_wr(prf_wr[2]),
      .free_list_free(free_list_free),

      .btq_pop(btq_pop),
      .ftq_redir(ftq_redir),
      .flush_pipeline(flush_pipeline),
      .idu_out_valid(inst_dec_out.valid),
      .rr_idle(rr_idle),
      .rat_sync(rat_sync),

      .lsq_pop(lsq_pop),
      .pmem(pmem[0])
  );

endmodule
