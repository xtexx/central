-Wall
-Wpedantic
-Werror-LATCH
-Werror-BLKANDNBLK
-Werror-CASEINCOMPLETE

--timescale "1ns / 1ps"
--top-module top

+define+SIMULATION
+define+SIMULATION_VERILATOR

config.vlt

-f tyro-core.f

vendor/tech_cells_generic/src/rtl/tc_clk.sv
vendor/tech_cells_generic/src/rtl/tc_sync.sv
