# Building

## With Zig

```sh
zig build
zig-out/bin/tyro-tb +verilator+rand+reset+2 2>sim.log
```

## With CMake

```sh
cmake -S . -B build
ninja -C build -j8
build/tyro-emu +verilator+rand+reset+2 2>sim.log
```

## With ModelSim

```sh
vlog -work questa -f tyro-core.questa.f
vopt +acc -work questa -o questa_opt questa.testbench
vsim -c -voptargs=+acc questa.questa_opt -do 'vcd file wave.vcd; vcd add /testbench/soc/uart0/clk; vcd add /testbench/soc/uart0/clk_io; vcd add /testbench/soc/uart0/clk_uart; vcd add /testbench/uart_tx; run -all; quit -f'
sigrok-cli -i wave.vcd -C uart_tx -P uart:tx=uart_tx:baudrate=4000000:data_bits=8:parity=none:stop_bits=1 -B uart=tx
```

## With Yosys & nextpnr

```sh
yosys synth.yosys.tcl
../nextpnr/build/nextpnr-himbaechel --json synth.json --write soc.pnr.json --device xc7k325tffg900-2 --chipdb ../nextpnr/xc7k325t.bin --sdc soc.sdc --vopt xdc=soc.xdc --vopt fasm=soc.pnr.fasm
```
