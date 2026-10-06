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
    // Data is the low 32 bits of target virtual address.
    InstCommitBranch,
    InstCommitException,
    InstCommitMem
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

  // LSQ entry
  typedef struct packed {
    // Data shift right (applied after mask)
    logic [2:0] shr;
    // Sign-extend (applied after bit shift)
    // 0 = EXT.W.B, 1 = EXT.W.H, 2 = EXT.W, 3 = NOP
    logic [1:0] ext;
    phy_reg_t dst;
    logic [64-3-2-$bits(phy_reg_t)-1:0] unused;
  } lsq_entry_ld_data_t;
  typedef struct packed {logic [63:0] data;} lsq_entry_st_data_t;
  typedef union packed {
    lsq_entry_ld_data_t ld;
    lsq_entry_st_data_t st;
  } lsq_entry_data_t;
  typedef struct packed {
    logic is_store;
    logic [63:0] addr;
    logic [7:0] strb;
    lsq_entry_data_t u;
  } lsq_entry_t  /*verilator public*/;

  // Instruction Data

  typedef logic [4:0] inst_gpr_t;
  typedef logic [13:0] inst_csr_t;

  typedef enum logic [5:0] {
    // Add or sub, Rw0 = Rr0 +- Rr1, uop_add_sub_pl_t, to ALU
    UOpAdd,
    // Add or sub, Rw0 = Rr0 +- pl.si12, uop_add_sub_pl_t, to ALU
    UOpAddImm,
    // Bit op, uop_bitop_pl_t, to ALU
    UOpBitOp,
    // Load immediate parts, uop_ld_imm_pl_t, to ALU
    UOpLdImm,
    // Bit string manipulation, uop_bstr_pl_t, to ALU
    UOpBitStr,
    // Trigger an exception, to CTL
    // pl[5:0] = Ecode
    // pl[14:6] = EsubCode
    UOpException,
    // Branch unconditionally, uop_br_pl_t, to BRU
    // Rw0 = PC + 4
    UOpBr,
    // Branch conditionally, uop_cond_br_pl_t, to BRU
    UOpCondBr,
    // Memory operation, uop_mem_pl_t, to AGU
    UOpMem
  } inst_opcode_t  /*verilator public*/;

  typedef logic [31:0] inst_payload_t;

  typedef struct packed {
    inst_opcode_t op;
    inst_payload_t pl;
    virt_reg_t [2:0] vregs_r;
    virt_reg_t [1:0] vregs_w;
    logic [63:0] pc;
  } decoded_inst_t  /*verilator public*/;

  typedef struct packed {
    inst_opcode_t op;
    inst_payload_t pl;
    phy_reg_t [2:0] pregs_r;
    phy_reg_t [1:0] pregs_w;
    rob_idx_t rob_idx;
  } rr_inst_t  /*verilator public*/;

  typedef struct packed {
    logic is_sub;  // Is SUB.[W/D]
    logic is_w;  // Is [ADD/SUB].W
    logic signed [11:0] si12;
  } uop_add_pl_t  /*verilator public*/;

  typedef enum logic [5:0] {
    BitOpTyAndImm = 6'b000000,
    BitOpTyOrImm = 6'b000001,
    BitOpTyXorImm = 6'b000010,
    BitOpTyAddu16id = 6'b000011,
    BitOpTyAnd = 6'b000100,
    BitOpTyAndn = 6'b000101,
    BitOpTyOr = 6'b000110,
    BitOpTyOrn = 6'b000111,
    BitOpTyXor = 6'b001000,
    BitOpTyNor = 6'b001001,
    BitOpTyMaskEqz = 6'b001010,
    BitOpTyMaskNez = 6'b001011,
    BitOpTyBitRevW = 6'b001100,
    BitOpTyBitRevD = 6'b001101,
    BitOpTyBitRev4B = 6'b001110,
    BitOpTyBitRev8B = 6'b001111,
    BitOpTyRevH2W = 6'b010000,
    BitOpTyRevHD = 6'b010001,
    BitOpTyRevB2H = 6'b010010,
    BitOpTyRevB4H = 6'b010011,
    BitOpTyRevB2W = 6'b010100,
    BitOpTyRevBD = 6'b010101,
    BitOpTyExtWB = 6'b010110,
    BitOpTyExtWH = 6'b010111,
    BitOpTyCLOW = 6'b011000,
    BitOpTyCLOD = 6'b011001,
    BitOpTyCLZW = 6'b011010,
    BitOpTyCLZD = 6'b011011,
    BitOpTyCTOW = 6'b011100,
    BitOpTyCTOD = 6'b011101,
    BitOpTyCTZW = 6'b011110,
    BitOpTyCTZD = 6'b011111,
    BitOpTySetLtS = 6'b100000,
    BitOpTySetLtU = 6'b100001,
    BitOpTySetLtSImm = 6'b100010,
    BitOpTySetLtUImm = 6'b100011,
    BitOpTySlAddW = 6'b100100,
    BitOpTySlAddWU = 6'b100101,
    BitOpTySlAddD = 6'b100110
  } uop_bitop_ty_t  /*verilator public*/;

  typedef struct packed {
    uop_bitop_ty_t ty;
    logic unsigned [15:0] ui16;
  } uop_bitop_pl_t  /*verilator public*/;

  typedef struct packed {
    logic is_w;
    logic is_ins;
    logic [5:0] msbw;
    logic [5:0] lsbw;
  } uop_bstr_pl_t  /*verilator public*/;

  typedef enum logic [2:0] {
    LdImmOpLU12IW = 3'b000,
    LdImmOpCU32ID = 3'b010,
    LdImmOpCU52ID = 3'b011,
    LdImmOpPCADDU2I = 3'b100,
    LdImmOpPCADDU12I = 3'b101,
    LdImmOpPCADDU18I = 3'b110,
    LdImmOpPCALAU12I = 3'b111
  } uop_ld_imm_op_t  /*verilator public*/;

  typedef struct packed {
    logic unsigned [19:0] imm;
    uop_ld_imm_op_t op;
  } uop_ld_imm_pl_t  /*verilator public*/;

  typedef struct packed {
    logic signed [25:0] offs26;
    logic base_reg;  // PC = (base_reg ? Rr0 : PC) + offset
  } uop_br_pl_t  /*verilator public*/;

  typedef enum logic [2:0] {
    BrCondEq  = 3'b000,
    BrCondNe  = 3'b001,
    BrCondGtS = 3'b010,
    BrCondGtU = 3'b011,
    BrCondLeS = 3'b100,
    BrCondLeU = 3'b101
  } uop_cond_br_type_t;

  typedef struct packed {
    logic signed [20:0] offs21;
    uop_cond_br_type_t  ty;
  } uop_cond_br_pl_t  /*verilator public*/;

  typedef enum logic [1:0] {
    MemOpTypeB,
    MemOpTypeH,
    MemOpTypeW,
    MemOpTypeD
  } mem_op_type_t  /*verilator public*/;

  typedef struct packed {
    logic is_store;
    // Target VADDR = Rr0 + Rr1 + offs (if !check_gt && !check_le)
    // Target VADDR = Rr0 (if check_gt || check_le)
    logic signed [15:0] offs;
    mem_op_type_t ty;
    logic is_unsigned;
    // Check Rr0 > Rr1
    logic check_gt;
    // Check Rr0 <= Rr1
    logic check_le;
  } uop_mem_pl_t  /*verilator public*/;

endpackage
