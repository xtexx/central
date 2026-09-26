const std = @import("std");

comptime {
    @export(&start, .{ .name = "start", .section = ".text.start" });
}

fn start() callconv(.naked) noreturn {
    asm volatile ("break 1");
}
