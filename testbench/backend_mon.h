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
  RROutWires &dp_o_alu, &dp_o_ctl, &dp_o_bru;
  RROutWires &alu_dq_out;
  CData &flush_pipeline;

public:
  inline explicit Monitor(PRegAllocWires *free_list_alloc,
                          PRegFreeWires *free_list_free,
                          ROBAllocWires *rob_alloc, ROBCommitWires *rob_commit,
                          ROBExecuteWires *rob_exec0,
                          ROBExecuteWires *rob_exec1,
                          ROBExecuteWires *rob_exec2, RROutWires *dp_o_alu,
                          RROutWires *dp_o_ctl, RROutWires *dp_o_bru,
                          RROutWires *alu_dq_out, CData *flush_pipeline)
      : free_list_alloc(*free_list_alloc), free_list_free(*free_list_free),
        rob_alloc(*rob_alloc), rob_commit(*rob_commit), dp_o_alu(*dp_o_alu),
        dp_o_ctl(*dp_o_ctl), dp_o_bru(*dp_o_bru), alu_dq_out(*alu_dq_out),
        flush_pipeline(*flush_pipeline) {
    rob_execute.push_back(rob_exec0);
    rob_execute.push_back(rob_exec1);
    rob_execute.push_back(rob_exec2);
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
