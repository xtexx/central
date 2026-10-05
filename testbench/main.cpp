#include "Vtyro.h"
#include "Vtyro___024root.h"
#include "core_mon.h"
#include "verilated.h"
#include "verilated_fst_c.h"
#include <filesystem>
#include <format>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

using namespace std;
using std::filesystem::path;

using namespace tyro::testbench;

int main(int argc, char **argv, char **env) {
  try {
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
    Monitor *mon = TYRO_TB_NEW_MONITOR(top->rootp, top__DOT__core__DOT__);

    // Load firmware
    top->eval();
    auto &sram = top->rootp->top__DOT__sram_mc__DOT__mem;
    sram.fill(0);
    auto fw_path = path("../firmware/zig-out/tyro-core-firmware.bin");
    cerr << "Loading firmware ...\n";
    auto fw_ifs = ifstream(fw_path, std::ios::binary);
    fw_ifs.read(reinterpret_cast<char *>(&sram.m_storage[0]),
                sizeof(sram.m_storage));
    if constexpr (std::endian::native == std::endian::big) {
      for (auto &v : sram.m_storage)
        v = std::byteswap(v);
    }
    cerr << "Firmware loaded\n";

    // Simulation loop
    auto cycles = 0ULL;
    while (!vctx->gotFinish()) {
      {
        std::ostringstream dump_buf;
        mon->dumpState(dump_buf);
        if (!dump_buf.view().empty()) {
          cerr << "@ " << cycles << "\n" << dump_buf.view();
        }
      }

      if (cycles == 10) {
        top->rst = 0;
        cerr << "Reset completed\n";
      }

      top->clk = 1;
      ++cycles;
      top->eval();
      trace->dump(vctx->time());
      vctx->timeInc(1);

      top->clk = 0;
      top->eval();
      trace->dump(vctx->time());
      vctx->timeInc(1);

      // Dump environment
      if (false) {
        for (auto i = 0U; i < 32; i++) {
          auto preg =
              top->rootp->top__DOT__core__DOT__committer__DOT__reg_aliases[i];
          auto preg_cell =
              top->rootp->top__DOT__core__DOT__int_prf__DOT__mem[preg];
          assert((preg_cell[2] & 1) == 1);
          unsigned long long val = ((preg_cell[1] | 0ULL) << 32) | preg_cell[0];
          if (i == 1)
            cerr << "ra";
          else if (i == 3)
            cerr << "sp";
          else
            cerr << "r" << i;
          cerr << " = " << std::format("{:016X}", val);
          if ((i % 4) == 3)
            cerr << '\n';
          else
            cerr << ' ';
        }
      }

      if (cycles == 100000)
        break;
    }
    top->final();
    trace->close();

    cerr << "Simulation end after " << cycles << " cycles\n";

    delete top;
    delete vctx;
    return 0;
  } catch (std::string &err) {
    cerr << "Testbench error: " << err << '\n';
    return 1;
  } catch (char const *err) {
    cerr << "Testbench error: " << err << '\n';
    return 1;
  }
}

namespace tyro {

int vl_printf(const char *format, ...) {
  char buf[1024];
  std::va_list args;
  va_start(args, format);
  int ret = std::vsnprintf(buf, sizeof(buf), format, args);
  va_end(args);
  if (ret >= 0) {
    std::cerr << "[VL] ";
    std::cerr.write(buf, ret);
  }
  return ret;
}

} // namespace tyro
