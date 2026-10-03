`timescale 1ns / 1ps
`default_nettype wire

package inst_pkg;

  // Register Aliasing

  typedef struct packed {logic [4:0] idx;} virt_reg_t  /*verilator public*/;
  typedef logic [5:0] phy_reg_t;

  // Re-Order Buffer

  typedef logic [2:0] rob_idx_t;

  typedef enum logic [1:0] {
    InstCommitNop = '0,
    InstCommitBranch,
    InstCommitException,
    InstCommitPhyMem
  } inst_commit_type_t  /*verilator public*/;

  typedef logic [31:0] inst_commit_data_t;

  parameter int unsigned ROB_ENTRY_REGS = 2;

  typedef struct packed {
    virt_reg_t vreg;
    phy_reg_t  new_preg;
  } rob_rr_entry_t  /*verilator public*/;

  typedef struct packed {
    logic [63:0] pc;
    // Ready for retirement
    logic ready;

    // Commit opcode
    inst_commit_type_t commit_type;
    inst_commit_data_t commit_data;

    // Register rename
    rob_rr_entry_t [ROB_ENTRY_REGS-1:0] rr;
  } rob_entry_t  /*verilator public*/;

  // BTQ entry
  typedef struct packed {
    logic hit;
    logic [63:0] addr;
  } branch_result_t  /*verilator public*/;

  // LSQ entry
  typedef struct packed {
    logic is_store;
    logic [63:0] addr;
  } load_store_t  /*verilator public*/;

  // Instruction Data

  typedef logic [4:0] inst_gpr_t;
  typedef logic [13:0] inst_csr_t;

  typedef enum logic [7:0] {
    // Add or sub, Rw0 = Rr0 +- Rr1, uop_add_sub_pl_t, to ALU
    UOpAdd,
    // Add or sub, Rw0 = Rr0 +- pl.si12, uop_add_sub_pl_t, to ALU
    UOpAddImm,
    // Bit op, Rw0 = Rr0 |&^ pl.ui12, uop_bitop_imm_pl_t, to ALU
    UOpBitOpImm,
    // Trigger an exception, to CTL
    // pl[5:0] = Ecode
    // pl[14:6] = EsubCode
    UOpException
  } inst_opcode_t  /*verilator public*/;

  typedef logic [31:0] inst_payload_t;

  typedef struct packed {
    inst_opcode_t op;
    inst_payload_t pl;
    virt_reg_t [1:0] vregs_r;
    virt_reg_t [1:0] vregs_w;
    logic [63:0] pc;
  } decoded_inst_t  /*verilator public*/;

  typedef struct packed {
    inst_opcode_t op;
    inst_payload_t pl;
    phy_reg_t [1:0] pregs_r;
    phy_reg_t [1:0] pregs_w;
    rob_idx_t rob_idx;
  } rr_inst_t  /*verilator public*/;

  typedef struct packed {
    logic is_sub;  // Is SUB.[W/D]
    logic is_w;  // Is [ADD/SUB].W
    logic signed [11:0] si12;
  } uop_add_pl_t  /*verilator public*/;

  typedef struct packed {
    logic unsigned [11:0] ui12;
    logic is_andi;
    logic is_ori;
    logic is_xori;
  } uop_bitop_imm_pl_t  /*verilator public*/;

endpackage
