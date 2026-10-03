cmake_minimum_required(VERSION 4.0)
project(tyro-core)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(verilator REQUIRED)

add_executable(tyro-emu
  testbench/main.cpp
  testbench/core_mon.cpp
  testbench/frontend_mon.cpp
  testbench/backend_mon.cpp
  testbench/monitor_utils.cpp
)
target_include_directories(tyro-emu PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/testbench)
target_compile_definitions(tyro-emu PRIVATE
  VL_VERILATED_INCLUDE="custom_verilated.h"
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
    --timescale "1ns / 1ps"
)
