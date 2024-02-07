const std = @import("std");
const log = std.log;
const hypearly_init = @import("hypearly_init");

pub const std_options = hypearly_init.std_options;
pub const log_prefix = "early-init";

pub fn main() !void {
    hypearly_init.init_logger();
    log.info("KLTE early-init", .{});

    const utsname = std.os.uname();
    if (std.mem.indexOf(u8, &utsname.version, "hyperpsi") == null) {
        log.warn("The kernel seems not to be for HyperPsi", .{});
    }
    log.info("{s} {s} {s}", .{ utsname.sysname, utsname.release, utsname.version });
}
