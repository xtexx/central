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
  PREFIX Vtyro
  SOURCES
    config.vlt
  VERILATOR_ARGS
    -f tyro-core.f

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
