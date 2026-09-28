const std = @import("std");

comptime {
    @export(&start, .{ .name = "start", .section = ".text.start" });
}

fn start() callconv(.naked) noreturn {
    asm volatile ("addi.d $r1, $r0, 1\naddi.d $r2, $r1, 1\nbreak 1");
}
