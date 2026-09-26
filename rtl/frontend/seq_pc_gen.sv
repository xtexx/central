`timescale 1ns / 1ps
`default_nettype none

module seq_pc_gen (
    input wire clk,
    input wire rst,
    ftq_addr_if.tx out_if,
    ftq_addr_if.rx redir_if
);

  logic [out_if.ADDR_W-1:0] pc;

  logic redir_hold;
  assign redir_hold = redir_if.valid & redir_if.ready;

  always_comb begin
    out_if.addr  = pc;
    out_if.valid = !redir_hold && !rst;
  end

  always_ff @(posedge clk) begin
    if (rst) pc <= 0;
    else begin
      if (redir_hold) begin
        pc <= redir_if.addr;
      end
      if (out_if.valid & out_if.ready) begin
        pc <= pc + 4;
      end
    end
  end

endmodule
