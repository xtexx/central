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
  InstDecOutWires &inst_dec_out;
  RROutWires &rr_out;

public:
  inline explicit Monitor(FTQAddrWires *ftq_out, FTQAddrWires *ftq_redir,
                          IFUOutWires *ifu_out, IFUOutWires *inst_buf_out,
                          InstDecOutWires *inst_dec_out, RROutWires *rr_out)
      : ftq_out(*ftq_out), ftq_redir(*ftq_redir), ifu_out(*ifu_out),
        inst_buf_out(*inst_buf_out), inst_dec_out(*inst_dec_out),
        rr_out(*rr_out) {}

  void dumpState(std::ostream &log);
  void dumpFTQAddr(std::ostream &log, FTQAddrWires &out,
                   const std::string &label);
  void dumpIFUOut(std::ostream &log, IFUOutWires &out,
                  const std::string &label);
  void dumpIDUOut(std::ostream &log, InstDecOutWires &out,
                  const std::string &label);
  void dumpRROut(std::ostream &log, RROutWires &out, const std::string &label);
};

} // namespace frontend
} // namespace testbench
} // namespace tyro
