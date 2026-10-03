#pragma once
#include "testbench.h"
#include <ostream>
#include <vector>

namespace tyro {
namespace testbench {
namespace backend {

class Monitor {
private:
  PRegAllocWires &free_list_alloc;
  PRegFreeWires &free_list_free;
  ROBAllocWires &rob_alloc;
  ROBCommitWires &rob_commit;
  std::vector<ROBExecuteWires *> rob_execute;
  RROutWires &dp_o_alu, &dp_o_ctl;
  RROutWires &alu_dq_out;

public:
  inline explicit Monitor(PRegAllocWires *free_list_alloc,
                          PRegFreeWires *free_list_free,
                          ROBAllocWires *rob_alloc, ROBCommitWires *rob_commit,
                          ROBExecuteWires *rob_exec0, RROutWires *dp_o_alu,
                          RROutWires *dp_o_ctl, RROutWires *alu_dq_out)
      : free_list_alloc(*free_list_alloc), free_list_free(*free_list_free),
        rob_alloc(*rob_alloc), rob_commit(*rob_commit), dp_o_alu(*dp_o_alu),
        dp_o_ctl(*dp_o_ctl), alu_dq_out(*alu_dq_out) {
    rob_execute.push_back(rob_exec0);
  }

  void dumpState(std::ostream &log);
  void dumpPRegAlloc(std::ostream &log, PRegAllocWires &wires,
                     const std::string &label);
  void dumpPRegFree(std::ostream &log, PRegFreeWires &wires,
                    const std::string &label);
  void dumpROBAlloc(std::ostream &log, ROBAllocWires &wires,
                    const std::string &label);
  void dumpROBCommit(std::ostream &log, ROBCommitWires &wires,
                     const std::string &label);
  void dumpROBExecute(std::ostream &log, ROBExecuteWires &wires,
                      const std::string &label, const unsigned int channel);
};

} // namespace backend
} // namespace testbench
} // namespace tyro
