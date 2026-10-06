#pragma once

#include <iostream>

#define VL_PRINTF ::tyro::vl_printf
#define TYRO_TB_UART_PUTC ::tyro::tb_uart_putc

namespace tyro {

int vl_printf(const char *format, ...);
inline void tb_uart_putc(const char ch) { std::cout << ch; }

} // namespace tyro
