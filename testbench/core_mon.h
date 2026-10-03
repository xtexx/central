#pragma once
#include "backend_mon.h"
#include "frontend_mon.h"

namespace tyro {
namespace testbench {

class Monitor {
private:
  frontend::Monitor frontend_mon;
  backend::Monitor backend_mon;

public:
  inline explicit Monitor(frontend::Monitor frontend_mon,
                          backend::Monitor backend_mon)
      : frontend_mon(frontend_mon), backend_mon(backend_mon) {};

  void dumpState(std::ostream &log);
};

#define TYRO_TB_NEW_MONITOR(top, prefix)                                       \
  new ::tyro::testbench::Monitor(                                              \
      ::tyro::testbench::frontend::Monitor(                                    \
          top->prefix##ftq_out, top->prefix##ftq_redir, top->prefix##ifu_out,  \
          top->prefix##inst_buf_out, top->prefix##inst_dec_out,                \
          top->prefix##rr_out),                                                \
      ::tyro::testbench::backend::Monitor(                                     \
          top->prefix##free_list_alloc, top->prefix##free_list_free,           \
          top->prefix##rob_alloc, top->prefix##rob_commit,                     \
          top->prefix##rob_exec__BRA__0__KET__, top->prefix##dp_o_alu,         \
          top->prefix##dp_o_ctl, top->prefix##alu_dq_out))

} // namespace testbench
} // namespace tyro
