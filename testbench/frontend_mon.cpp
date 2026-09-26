#include "frontend_mon.h"
#include "monitor_utils.h"
#include "testbench.h"

namespace tyro {
namespace testbench {
namespace frontend {

using namespace monitor_utils;

enum ifu_out_resp_t : uint8_t {
  IFUOutSuccess = 0b00,
  IFUOutTLBRefill = 0b01,
  IFUOutMachErr = 0b10
};

void Monitor::dumpState(std::ostream &log) {
  dumpFTQAddr(log, ftq_out, "FTQ out");
  dumpFTQAddr(log, ftq_redir, "FTQ redir");
  dumpIFUOut(log, ifu_out, "IFU out");
  dumpIFUOut(log, inst_buf_out, "IB out");
}

void Monitor::dumpFTQAddr(std::ostream &log, FTQAddrWires &out,
                          const std::string &label) {
  if (out.rst)
    log << FmtRst(label);
  else if (out.valid && out.ready) {
    log << label << ": " << FmtQAddr(out.addr, out.ADDR_W) << '\n';
  }
}

void Monitor::dumpIFUOut(std::ostream &log, IFUOutWires &out,
                         const std::string &label) {
  if (out.rst)
    log << FmtRst(label);
  else if (out.valid && out.ready) {
    log << label << " @" << FmtQAddr(out.pc, out.ADDR_W) << ": ";
    auto resp = static_cast<ifu_out_resp_t>(out.resp);
    switch (resp) {
    case IFUOutSuccess: {
      auto inst = out.inst;
      log << std::format("{:02X} {:02X} {:02X} {:02X}", inst & 0xFF,
                         (inst >> 8) & 0xFF, (inst >> 16) & 0xFF,
                         (inst >> 24) & 0xFF)
          << '\n';
      break;
    }
    case IFUOutTLBRefill: {
      log << "TLB refill\n";
      break;
    }
    case IFUOutMachErr: {
      log << "machine error exception\n";
      break;
    }
    default:
      throw "Unexpected ifu_out.resp";
    }
  }
}

} // namespace frontend
} // namespace testbench
} // namespace tyro
