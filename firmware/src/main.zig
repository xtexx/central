const std = @import("std");

const Uart = @import("device/Uart.zig");

comptime {
    @export(&start0, .{ .name = "start", .section = ".text.start" });
}

// pub const std_options: std.Options = .{
//     .allow_stack_tracing = false,
//     .page_size_max = 64,
//     .page_size_min = 64,
//     .queryPageSize = mockPageSize,
//     .unexpected_error_tracing = false,
// };

// fn mockPageSize() usize {
//     return 64;
// }

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

    // var heap_allocator: std.heap.FixedBufferAllocator = .init(&heap);
    // const gpa = heap_allocator.allocator();
    // const str = gpa.print("CF0={x}\nCF1={x}\n", .{ cpucfg(0), cpucfg(1) }) catch unreachable;
    const str = std.fmt.bufPrint(&heap, "CF0={x}\nCF1={x}\n", .{ cpucfg(0), cpucfg(1) }) catch unreachable;
    uart0.sendBytes(str);

    uart0.sendBytes("End\n");

    while (true) {}
}

fn cpucfg(word: u32) u32 {
    return asm ("cpucfg %[result], %[word]"
        : [result] "=r" (-> u32),
        : [word] "r" (word),
    );
}
