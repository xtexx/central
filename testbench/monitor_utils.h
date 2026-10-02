#pragma once
#include "testbench.h"
#include "verilated.h"

namespace tyro {
namespace testbench {
namespace monitor_utils {

class FmtRst {
public:
  const std::string &component;

  inline explicit FmtRst(const std::string &component) : component(component) {}
};

inline std::ostream &operator<<(std::ostream &os, const FmtRst &h) {
  return os << "RST: " << h.component << " reset\n";
}

class FmtQAddr {
public:
  const QData addr;
  const unsigned short bits;

  inline explicit FmtQAddr(const QData addr, const unsigned short bits)
      : addr(addr), bits(bits) {}
};

inline std::ostream &operator<<(std::ostream &os, const FmtQAddr &h) {
  return os << std::format("0x{:0{}X}", h.addr, (h.bits + 3) / 4);
}

class FmtVReg {
public:
  const virt_reg_t &reg;

  inline explicit FmtVReg(const virt_reg_t &reg) : reg(reg) {}
};

inline std::ostream &operator<<(std::ostream &os, const FmtVReg &h) {
  return os << "$r" << (unsigned int)h.reg.idx;
}

void dumpDecodedInstructionOp(std::ostream &log, const SData op,
                              const IData raw_pl);

} // namespace monitor_utils
} // namespace testbench
} // namespace tyro
