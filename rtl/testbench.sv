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
  initial rst = 1;
  always #1 clk = ~clk;

  initial begin
    #2;
    $readmemh("firmware/zig-out/tyro-core-firmware.hex", platform.sram_mc.mem);
    #11;
    rst = 0;

    repeat (10000) @(posedge clk);

    $display("All tests done.");
    $finish();
  end
endmodule
