#pragma once
#include "Vtyro_ftq_addr_if.h"
#include "Vtyro_ifu_out_if.h"
#include "Vtyro_inst_dec_out_if.h"
#include "Vtyro_inst_pkg.h"

namespace tyro {
namespace testbench {

typedef Vtyro_ftq_addr_if FTQAddrWires;
typedef Vtyro_ifu_out_if IFUOutWires;
typedef Vtyro_inst_dec_out_if InstDecOutWires;

typedef Vtyro_virt_reg_t__struct__0 virt_reg_t;
typedef Vtyro_decoded_inst_t__struct__0 decoded_inst_t;
typedef Vtyro_inst_pkg inst_pkg;
typedef Vtyro_uop_add_pl_t__struct__0 uop_add_pl_t;
typedef Vtyro_uop_bitop_imm_pl_t__struct__0 uop_bitop_imm_pl_t;

} // namespace testbench
} // namespace tyro
