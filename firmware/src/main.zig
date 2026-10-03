const std = @import("std");

comptime {
    @export(&start, .{ .name = "start", .section = ".text.start" });
}

fn start() callconv(.naked) noreturn {
    asm volatile (
        \\li.d $sp, 0xff00
        \\b %[main]
        :
        : [main] "X" (&main),
    );
}

fn main() noreturn {
    @call(.never_inline, b, .{});
    while (true) {}
}

export fn b() void {
    asm volatile ("break 1");
}
