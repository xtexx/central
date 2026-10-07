#include "monitor_utils.h"
#include "testbench.h"

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
  case inst_pkg::UOpBitOp: {
    uop_bitop_pl_t pl;
    pl.set(raw_pl);
    log << std::format("BitOp ty={} imm={}", pl.ty, pl.ui16);
    break;
  }
  case inst_pkg::UOpBitShift: {
    uop_bit_shift_pl_t pl;
    pl.set(raw_pl);
    log << std::format("BitShift ty={} is_w={} is_imm={} imm={}", pl.ty,
                       pl.is_w, pl.is_imm, pl.imm);
    break;
  }
  case inst_pkg::UOpLdImm: {
    uop_ld_imm_pl_t pl;
    pl.set(raw_pl);
    log << std::format("LdImm op={} imm=", pl.op) << FmtQAddr(pl.imm, 20);
    break;
  }
  case inst_pkg::UOpBitStr: {
    uop_bstr_pl_t pl;
    pl.set(raw_pl);
    log << std::format("BitStr is_w={} is_ins={} msbw={} lsbw={}", pl.is_w,
                       pl.is_ins, pl.msbw, pl.lsbw);
    break;
  }
  case inst_pkg::UOpBr: {
    uop_br_pl_t pl;
    pl.set(raw_pl);
    log << std::format("Br base_reg={} offs26=", pl.base_reg)
        << FmtQAddr(pl.offs26, 26);
    break;
  }
  case inst_pkg::UOpCondBr: {
    uop_cond_br_pl_t pl;
    pl.set(raw_pl);
    log << std::format("CondBr ty={} offs21=", pl.ty)
        << FmtQAddr(pl.offs21, 21);
    break;
  }
  case inst_pkg::UOpMem: {
    uop_mem_pl_t pl;
    pl.set(raw_pl);
    log << std::format("Mem is_st={} is_u={} ty={} offs=", pl.is_store,
                       pl.is_unsigned, pl.ty)
        << FmtQAddr(pl.offs, 16);
    break;
  }
  case inst_pkg::UOpMul: {
    log << std::format("Mul pl={}", raw_pl);
    break;
  }
  default:
    log << "???";
  }
}

} // namespace monitor_utils
} // namespace testbench
} // namespace tyro
