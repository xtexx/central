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

} // namespace testbench
} // namespace tyro
