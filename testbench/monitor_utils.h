#pragma once
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

} // namespace monitor_utils
} // namespace testbench
} // namespace tyro
