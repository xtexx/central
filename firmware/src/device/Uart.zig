/// UART Controller
const Uart = @This();

const std = @import("std");
const assert = std.debug.assert;

const Registers = extern struct {
    tx_fifo: u8 align(1),
    freq_pattern: u64 align(8),
};

regs: *align(64) volatile Registers,

/// Calculates frequency divider pattern configuration.
pub fn calcFreqPatternConfig(ref_freq: u64, target_freq: u64) [4]u16 {
    const RatioF = f128;

    const ratio = @as(RatioF, ref_freq) / 2 / @as(RatioF, target_freq);
    assert(ratio >= 1);
    var cfg: [4]u16 = @splat(@trunc(ratio));
    const frac = ratio - @trunc(ratio);

    // 0.125 = (1 / 2) / 4 (PATTERN_N)
    if (frac > 0.125) cfg[1] += 1;
    if (frac > 0.375) cfg[3] += 1;
    if (frac > 0.625) cfg[0] += 1;
    if (frac > 0.875) cfg[2] += 1;

    const final_ratio = @as(RatioF, cfg[0] + cfg[1] + cfg[2] + cfg[3]) / 4;
    assert(@abs(final_ratio - ratio) < 0.125 + 1e-12);
    const output_freq = @as(RatioF, ref_freq) / (final_ratio * 2);
    const freq_diff = (output_freq / @as(RatioF, target_freq)) - 1.0;
    assert(@abs(freq_diff) < 0.04);

    for (0..4) |i| cfg[i] -= 1;
    return cfg;
}

/// Set frequency divider ratio configuration.
pub fn setFreqDivPattern(uart: Uart, pattern: [4]u16) void {
    @atomicStore(u64, &uart.regs.freq_pattern, @bitCast(pattern), .unordered);
}

/// Set baud rate.
pub fn setBaudRate(uart: Uart, comptime baud_rate: u64) void {
    const io_clock_freq = 250 * 1000 * 1000;
    // const io_clock_freq = 500 * 1000 * 1000 * 1000;
    uart.setFreqDivPattern(comptime calcFreqPatternConfig(io_clock_freq, 16 * baud_rate));
}

/// Send a byte to the FIFO buffer.
pub inline fn sendByte(uart: Uart, char: u8) void {
    @atomicStore(u8, &uart.regs.tx_fifo, char, .unordered);
}
