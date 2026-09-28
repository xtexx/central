#pragma once
#include "frontend_mon.h"

namespace tyro {
namespace testbench {

class Monitor {
private:
  frontend::Monitor frontend_mon;

public:
  inline explicit Monitor(frontend::Monitor frontend_mon)
      : frontend_mon(frontend_mon) {};

  void dumpState(std::ostream &log);
};

#define TYRO_TB_NEW_MONITOR(top, prefix)                                       \
  new ::tyro::testbench::Monitor(::tyro::testbench::frontend::Monitor(         \
      top->prefix##__DOT__ftq_out, top->prefix##__DOT__ftq_redir,              \
      top->prefix##__DOT__ifu_out, top->prefix##__DOT__inst_buf_out,           \
      top->prefix##__DOT__inst_dec_out))

} // namespace testbench
} // namespace tyro
