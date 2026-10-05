const std = @import("std");

comptime {
    @export(&start0, .{ .name = "start", .section = ".text.start" });
}

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
        \\st.d $r3, $r0, 0x50
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
