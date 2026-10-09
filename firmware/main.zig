const std = @import("std");

const Uart = @import("device/Uart.zig");

comptime {
    @export(&start0, .{ .name = "start", .section = ".text.start" });
}

const uart0: Uart = .{ .regs = @ptrFromInt(0x0000100000) };

var heap: [1024]u8 = undefined;

fn start0() callconv(.naked) noreturn {
    asm volatile (
        \\ // Reset instructions
        \\ b %[start1]
        \\ b %[start1]
        :
        : [start1] "X" (&start1),
    );
}

fn start1() callconv(.naked) noreturn {
    asm volatile (
        \\ li.d $sp, 0xff00
        \\ b %[main]
        :
        : [main] "X" (&main),
    );
}

fn main() noreturn {
    // 9600 is too slow for simulation.
    // uart0.setBaudRate(9600);
    // uart0.setBaudRate(100000000);
    uart0.setBaudRate(4000000);
    uart0.sendBytes("Tyro Core Firmware Early Initialization\n");

    var heap_allocator: std.heap.FixedBufferAllocator = .init(&heap);
    const gpa = heap_allocator.allocator();
    const str = gpa.print("CPUCFG0={x}\nCPUCFG1={x}\n", .{ cpucfg(0), cpucfg(1) }) catch unreachable;
    uart0.sendBytes(str);

    // Call U-Boot
    uart0.sendBytes("Starting U-Boot...\n");
    asm volatile (
        \\ li.d $r4, 0x200000
        \\ jirl $r0, $r4, 0
    );

    while (true) {}
}

fn cpucfg(word: u32) u32 {
    return asm ("cpucfg %[result], %[word]"
        : [result] "=r" (-> u32),
        : [word] "r" (word),
    );
}
