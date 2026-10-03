#include "backend_mon.h"
#include "frontend_mon.h"
#include "monitor_utils.h"
#include "testbench.h"

namespace tyro {
namespace testbench {
namespace backend {

using namespace monitor_utils;

void Monitor::dumpState(std::ostream &log) {
  dumpPRegAlloc(log, free_list_alloc, "Free List");
  dumpPRegFree(log, free_list_free, "Free List");

  dumpROBAlloc(log, rob_alloc, "ROB alloc");
  dumpROBCommit(log, rob_commit, "ROB commit");
  for (unsigned int i = 0; i < rob_execute.size(); i++)
    dumpROBExecute(log, *rob_execute[i], "ROB execute", i);

  frontend::Monitor::dumpRROut(log, dp_o_alu, "Dispatch to ALU");
  frontend::Monitor::dumpRROut(log, dp_o_ctl, "Dispatch to CTL");

  frontend::Monitor::dumpRROut(log, alu_dq_out, "ALU DQ out");
}

void Monitor::dumpPRegAlloc(std::ostream &log, PRegAllocWires &wires,
                            const std::string &label) {
  if (wires.rst)
    log << FmtRst(label);
  else {
    for (unsigned int i = 0; i < wires.used; i++) {
      assert(((wires.valid >> i) & 1) == 1);
      log << label << ": pop " << (unsigned int)wires.preg[i] << '\n';
    }
  }
}

void Monitor::dumpPRegFree(std::ostream &log, PRegFreeWires &wires,
                           const std::string &label) {
  if (wires.rst)
    log << FmtRst(label);
  else {
    for (unsigned int i = 0; i < wires.BATCH_SIZE; i++) {
      if (((wires.valid >> i) & 1) == 1) {
        log << label << ": push " << (unsigned int)wires.preg[i] << '\n';
      }
    }
  }
}

void Monitor::dumpROBAlloc(std::ostream &log, ROBAllocWires &wires,
                           const std::string &label) {
  if (wires.rst)
    log << FmtRst(label);
  else if (wires.valid & wires.ready) {
    log << label << ": " << (unsigned int)wires.idx
        << ", pc=" << FmtQAddr(wires.pc, 64);
    for (unsigned int i = 0; i < wires.rr.size(); i++) {
      rob_rr_entry_t rr_entry;
      rr_entry.set(wires.rr[i]);
      log << ", rr=" << FmtVReg(rr_entry.vreg) << "=pr"
          << (unsigned int)rr_entry.new_preg;
    }
    log << '\n';
  }
}

static void dumpROBCommitPayload(std::ostream &log, CData raw_type,
                                 IData raw_data) {
  auto commit_type = static_cast<inst_pkg::inst_commit_type_t>(raw_type);
  switch (commit_type) {
  case inst_pkg::InstCommitNop: {
    log << "nop";
    break;
  }
  case inst_pkg::InstCommitBranch: {
    log << "branch";
    // TODO commit data
    break;
  }
  case inst_pkg::InstCommitException: {
    log << "exception";
    // TODO commit data
    break;
  }
  case inst_pkg::InstCommitPhyMem: {
    log << "memory access";
    // TODO commit data
    break;
  }
  default:
    throw "Unexpected ROB entry commit type";
  }
}

void Monitor::dumpROBCommit(std::ostream &log, ROBCommitWires &wires,
                            const std::string &label) {
  if (wires.rst)
    log << FmtRst(label);
  else if (wires.valid & wires.ready) {
    rob_entry_t entry;
    entry.set(wires.entry);
    assert(entry.ready);
    log << label << ": pc=" << FmtQAddr(entry.pc, 64);

    constexpr unsigned int ROB_ENTRY_REGS =
        sizeof(entry.rr) / sizeof(rob_rr_entry_t);
    for (unsigned int i = 0; i < ROB_ENTRY_REGS; i++) {
      rob_rr_entry_t rr_entry = entry.rr[i];
      log << ", rr=" << FmtVReg(rr_entry.vreg) << "=pr" << rr_entry.new_preg;
    }

    log << ", commit=";
    dumpROBCommitPayload(log, entry.commit_type, entry.commit_data);
    log << '\n';
  }
}

void Monitor::dumpROBExecute(std::ostream &log, ROBExecuteWires &wires,
                             const std::string &label,
                             const unsigned int channel) {
  if (wires.rst)
    log << FmtRst(label);
  else if (wires.valid) {
    log << label << "#" << channel << ": entry=" << wires.idx << ", commit=";
    dumpROBCommitPayload(log, wires.commit_type, wires.data);
    log << '\n';
  }
}

} // namespace backend
} // namespace testbench
} // namespace tyro
