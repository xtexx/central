#pragma once
#include "testbench.h"
#include <ostream>

namespace tyro {
namespace testbench {
namespace frontend {

class Monitor {
private:
  FTQAddrWires &ftq_out;
  FTQAddrWires &ftq_redir;
  IFUOutWires &ifu_out;
  IFUOutWires &inst_buf_out;

public:
  inline explicit Monitor(FTQAddrWires *ftq_out, FTQAddrWires *ftq_redir,
                          IFUOutWires *ifu_out, IFUOutWires *inst_buf_out)
      : ftq_out(*ftq_out), ftq_redir(*ftq_redir), ifu_out(*ifu_out),
        inst_buf_out(*inst_buf_out) {}

  void dumpState(std::ostream &log);
  void dumpFTQAddr(std::ostream &log, FTQAddrWires &out,
                   const std::string &label);
  void dumpIFUOut(std::ostream &log, IFUOutWires &out,
                  const std::string &label);
};

} // namespace frontend
} // namespace testbench
} // namespace tyro
