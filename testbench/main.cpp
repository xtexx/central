#include "Vtyro.h"
#include "Vtyro___024root.h"
#include "core_mon.h"
#include "verilated.h"
#include "verilated_fst_c.h"
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>

using namespace std;
using std::filesystem::path;

using namespace tyro::testbench;

int main(int argc, char **argv, char **env) {
  VerilatedContext *vctx = new VerilatedContext();
  vctx->traceEverOn(true);
  vctx->commandArgs(argc, argv);

  VerilatedFstC *trace = new VerilatedFstC();
  trace->set_time_resolution("1ps");
  trace->set_time_unit("1ps");

  Vtyro *top = new Vtyro(vctx);
  top->clk = 0;
  top->rst = 1;

  // Setup tracing
  top->trace(trace, 20);
  trace->open("wave.fst");

  // Setup monitor
  Monitor *mon = TYRO_TB_NEW_MONITOR(top->rootp, __PVT__top__DOT__core);

  // Load firmware
  top->eval();
  auto &sram = top->rootp->top__DOT__sram_mc__DOT__mem;
  sram.fill(0);
  auto fw_path = path("../firmware/zig-out/tyro-core-firmware.bin");
  cout << "Loading firmware ...\n";
  auto fw_ifs = ifstream(fw_path, std::ios::binary);
  fw_ifs.read(reinterpret_cast<char *>(&sram.m_storage[0]),
              sizeof(sram.m_storage));
  if constexpr (std::endian::native == std::endian::big) {
    for (auto &v : sram.m_storage)
      v = std::byteswap(v);
  }
  cout << "Firmware loaded\n";

  // Simulation loop
  auto cycles = 0ULL;
  auto last_dump_cycles = 0ULL;
  while (!vctx->gotFinish()) {
    {
      std::ostringstream dump_buf;
      mon->dumpState(dump_buf);
      if (!dump_buf.view().empty()) {
        auto delta_time = cycles - last_dump_cycles;
        cout << "@ " << cycles << " (+" << delta_time << ")\n";
        cout << dump_buf.view();
        last_dump_cycles = cycles;
      }
    }

    top->clk = 1;
    ++cycles;
    top->eval();
    trace->dump(vctx->time());
    vctx->timeInc(1);

    if (cycles == 10) {
      top->rst = 0;
      cout << "Reset completed\n";
    }

    top->clk = 0;
    top->eval();
    trace->dump(vctx->time());
    vctx->timeInc(1);

    if (cycles == 100000)
      break;
  }
  top->final();
  trace->close();

  cout << "Simulation end after " << cycles << " cycles\n";

  delete top;
  delete vctx;
  return 0;
}
