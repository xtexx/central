`timescale 1ns / 1ps
`default_nettype wire

module testbench ();
  logic clk;
  logic rst;

  top platform (
      .clk(clk),
      .rst(rst)
  );

  initial clk = 0;
  always #2 clk = ~clk;

  initial begin
    rst = 1;
    $readmemh("firmware/zig-out/tyro-core-firmware.hex", platform.sram_mc.mem);
    #20;
    rst = 0;

    repeat (10000) @(posedge clk);

    $display("All tests done.");
    $finish();
  end
endmodule
