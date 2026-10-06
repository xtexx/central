`timescale 1ns / 1ps
`default_nettype wire

module testbench ();
  logic clk, clk_io_ref;
  logic rst;
  logic uart_tx;

  top soc (
      .clk(clk),
      .rst(rst),
      .clk_io_ref(clk_io_ref),
      .uart_tx(uart_tx)
  );

  // Main clock, 500 MHz
  initial clk = 0;
  always #1 clk = ~clk;
  // IO reference clock, 250 MHz
  initial clk_io_ref = 0;
  always #2 clk_io_ref = ~clk_io_ref;

  initial rst = 1;

  initial begin
    #2;
    $readmemh("firmware/zig-out/tyro-core-firmware.hex", soc.sram_mc.mem);
    #11;
    rst = 0;

    repeat (200000) @(posedge clk);

    $display("All tests done.");
    $finish();
  end
endmodule
