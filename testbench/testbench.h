#pragma once
#include "Vtyro_ftq_addr_if.h"
#include "Vtyro_ifu_out_if.h"
#include "Vtyro_inst_dec_out_if.h"
#include "Vtyro_inst_pkg.h"
#include "Vtyro_preg_alloc_if__B3.h"
#include "Vtyro_preg_free_if__B2.h"
#include "Vtyro_prf_read_if.h"
#include "Vtyro_prf_reset_if.h"
#include "Vtyro_prf_write_if.h"
#include "Vtyro_rob_alloc_if.h"
#include "Vtyro_rob_commit_if.h"
#include "Vtyro_rob_execute_if.h"
#include "Vtyro_rr_out_if.h"

namespace tyro {
namespace testbench {

// Frontend
typedef Vtyro_ftq_addr_if FTQAddrWires;
typedef Vtyro_ifu_out_if IFUOutWires;
typedef Vtyro_inst_dec_out_if InstDecOutWires;
typedef Vtyro_rr_out_if RROutWires;

// inst_pkg
typedef Vtyro_inst_pkg inst_pkg;
typedef Vtyro_virt_reg_t__struct__0 virt_reg_t;
typedef Vtyro_decoded_inst_t__struct__0 decoded_inst_t;
typedef Vtyro_rr_inst_t__struct__0 rr_inst_t;
typedef Vtyro_rob_rr_entry_t__struct__0 rob_rr_entry_t;
typedef Vtyro_rob_entry_t__struct__0 rob_entry_t;
typedef Vtyro_uop_add_pl_t__struct__0 uop_add_pl_t;
typedef Vtyro_uop_bitop_imm_pl_t__struct__0 uop_bitop_imm_pl_t;
typedef Vtyro_uop_ld_imm_pl_t__struct__0 uop_ld_imm_pl_t;
typedef Vtyro_uop_bstr_pl_t__struct__0 uop_bstr_pl_t;
typedef Vtyro_uop_br_pl_t__struct__0 uop_br_pl_t;
typedef Vtyro_uop_mem_pl_t__struct__0 uop_mem_pl_t;

// Backend
typedef Vtyro_preg_alloc_if__B3 PRegAllocWires;
typedef Vtyro_preg_free_if__B2 PRegFreeWires;
typedef Vtyro_prf_read_if PRFReadWires;
typedef Vtyro_prf_write_if PRFWriteWires;
typedef Vtyro_prf_reset_if PRFResetWires;
typedef Vtyro_rob_alloc_if ROBAllocWires;
typedef Vtyro_rob_commit_if ROBCommitWires;
typedef Vtyro_rob_execute_if ROBExecuteWires;

} // namespace testbench
} // namespace tyro
