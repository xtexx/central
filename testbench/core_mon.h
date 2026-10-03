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
          top->__PVT__##prefix##ftq_out, top->__PVT__##prefix##ftq_redir,      \
          top->__PVT__##prefix##ifu_out, top->__PVT__##prefix##inst_buf_out,   \
          top->__PVT__##prefix##inst_dec_out, top->__PVT__##prefix##rr_out),   \
      ::tyro::testbench::backend::Monitor(                                     \
          top->__PVT__##prefix##free_list_alloc,                               \
          top->__PVT__##prefix##free_list_free,                                \
          top->__PVT__##prefix##rob_alloc, top->__PVT__##prefix##rob_commit,   \
          top->__PVT__##prefix##rob_exec__BRA__0__KET__,                       \
          top->__PVT__##prefix##rob_exec__BRA__1__KET__,                       \
          top->__PVT__##prefix##rob_exec__BRA__2__KET__,                       \
          top->__PVT__##prefix##dp_o_alu, top->__PVT__##prefix##dp_o_ctl,      \
          top->__PVT__##prefix##dp_o_bru, top->__PVT__##prefix##alu_dq_out,    \
          &top->prefix##flush_pipeline))

} // namespace testbench
} // namespace tyro
