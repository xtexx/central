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
  dumpIDUOut(log, inst_dec_out, "ID out");
  dumpRROut(log, rr_out, "RR out");
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

void Monitor::dumpIDUOut(std::ostream &log, InstDecOutWires &out,
                         const std::string &label) {
  if (out.rst)
    log << FmtRst(label);
  else if (out.valid && out.ready) {
    decoded_inst_t inst;
    inst.set(out.inst);

    log << label << " @" << FmtQAddr(inst.pc, 64) << ": ";
    dumpDecodedInstructionOp(log, inst.op, inst.pl);
    log << " (R=" << FmtVReg(inst.vregs_r[0]) << " " << FmtVReg(inst.vregs_r[1])
        << " " << FmtVReg(inst.vregs_r[2]) << ", W=" << FmtVReg(inst.vregs_w[0])
        << " " << FmtVReg(inst.vregs_w[1]) << ")\n";
  }
}

void Monitor::dumpRROut(std::ostream &log, RROutWires &out,
                        const std::string &label) {
  if (out.rst)
    log << FmtRst(label);
  else if (out.valid && out.ready) {
    rr_inst_t inst;
    inst.set(out.inst);

    log << label << ": ROB idx=" << (unsigned int)inst.rob_idx << ", op=";
    dumpDecodedInstructionOp(log, inst.op, inst.pl);
    log << " (R=pr" << (unsigned int)inst.pregs_r[0] << " pr"
        << (unsigned int)inst.pregs_r[1] << " pr"
        << (unsigned int)inst.pregs_r[2] << ", W=pr"
        << (unsigned int)inst.pregs_w[0] << " pr"
        << (unsigned int)inst.pregs_w[1] << ")\n";
  }
}

} // namespace frontend
} // namespace testbench
} // namespace tyro
