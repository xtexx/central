#include "core_mon.h"
#include <ostream>

namespace tyro {
namespace testbench {

void Monitor::dumpState(std::ostream &log) {
  this->frontend_mon.dumpState(log);
}

} // namespace testbench
} // namespace tyro
