const std = @import("std");

const Uart = @import("device/Uart.zig");

comptime {
    @export(&start0, .{ .name = "start", .section = ".text.start" });
}

const uart0: Uart = .{ .regs = @ptrFromInt(0x0000100000) };

fn start0() callconv(.naked) noreturn {
    asm volatile (
        \\b %[start1]
        \\b %[start1]
        :
        : [start1] "X" (&start1),
    );
}

fn start1() callconv(.naked) noreturn {
    asm volatile (
        \\li.d $sp, 0xff00
        // \\alsl.w $r4, $sp, $r0, 4
        // \\st.d $r4, $r0, 0x1050
        \\b %[main]
        :
        : [main] "X" (&main),
    );
}

fn main() noreturn {
    // 9600 is too slow for simulation.
    // uart0.setBaudRate(9600);
    // uart0.setBaudRate(100000000);
    uart0.setBaudRate(4000000);
    for ("你好世界喵喵喵\n") |c| uart0.sendByte(c);
    while (true) {}
}

export fn b() void {
    asm volatile ("break 1");
}
