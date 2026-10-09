#pragma once

#include <cstddef>

#if defined(__cpp_lib_endian) && __cpp_lib_endian >= 201907L
#include <bit>
using std::endian;
#else
enum class endian {
  little = 0,
  big = 1,
#if defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
  native = big
#elif defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
  native = little
#else
#error "Cannot determine native byte order"
#endif
};
#endif

#if defined(__cpp_lib_byteswap) && __cpp_lib_byteswap >= 202110L
#include <bit>
using std::byteswap;
#else
template <typename T> constexpr T byteswap(T value) noexcept {
  T result = 0;
  for (size_t i = 0; i < sizeof(T); ++i) {
    result = (result << 8) | (value & 0xFF);
    value >>= 8;
  }
  return result;
}
#endif
