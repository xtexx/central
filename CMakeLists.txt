cmake_minimum_required(VERSION 4.0)
project(tyro-core)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(verilator REQUIRED)

add_executable(tyro-emu
  testbench/main.cpp
  testbench/core_mon.cpp
  testbench/frontend_mon.cpp
)
set_target_properties(tyro-emu PROPERTIES
  CXX_STANDARD 23
  CXX_STANDARD_REQUIRED ON
  CXX_EXTENSIONS OFF
)

verilate(tyro-emu
  TRACE_FST THREADS
  INCLUDE_DIRS
    rtl rtl/utils rtl/interface
    rtl/mem rtl/frontend
    vendor/common_cells/include vendor/common_cells/src
    vendor/taxi/src/axi/rtl
  PREFIX Vtyro
  SOURCES
    config.vlt
    vendor/common_cells/src/cc_pkg.sv
    rtl/frontend/ifu_pkg.sv
    rtl/top.sv
  VERILATOR_ARGS
    -Werror-LATCH
    -Werror-BLKANDNBLK
    -Werror-CASEINCOMPLETE
    -Wall
    -Wpedantic
    -Wno-UNDRIVEN
    -Wno-UNUSEDSIGNAL
    -Wno-UNUSEDPARAM
    --timescale "1ns / 1ps"
)
