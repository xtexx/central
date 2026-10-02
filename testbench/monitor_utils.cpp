#include "monitor_utils.h"

namespace tyro {
namespace testbench {
namespace monitor_utils {

void dumpDecodedInstructionOp(std::ostream &log, const SData op,
                              const IData raw_pl) {
  auto opcode = static_cast<inst_pkg::inst_opcode_t>(op);
  switch (opcode) {
  case inst_pkg::UOpException: {
    auto ecode = raw_pl & 0b111111;
    log << std::format("Exception Ecode={:02X} EsubCode={:02X}", ecode,
                       raw_pl >> 6);
    switch (ecode) {
    case 0x0B: {
      log << " SYS";
      break;
    }
    case 0x0C: {
      log << " BRK";
      break;
    }
    case 0x0D: {
      log << " INE";
      break;
    }
    }
    break;
  }
  case inst_pkg::UOpAdd:
  case inst_pkg::UOpAddImm: {
    uop_add_pl_t pl;
    pl.set(raw_pl);
    log << (opcode == inst_pkg::UOpAdd ? "Add" : "AddImm")
        << std::format(" is_sub={} is_w={} si12={}", pl.is_sub, pl.is_w,
                       pl.si12);
    break;
  }
  case inst_pkg::UOpBitOpImm: {
    uop_bitop_imm_pl_t pl;
    pl.set(raw_pl);
    log << std::format("BitOpImm is_andi={} is_ori={} is_xori={} ui12={}",
                       pl.is_andi, pl.is_ori, pl.is_xori, pl.ui12);
    break;
  }
  default:
    throw "Unexpected idu_out.op";
  }
}

} // namespace monitor_utils
} // namespace testbench
} // namespace tyro
