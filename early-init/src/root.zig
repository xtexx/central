const std = @import("std");
const log = std.log;
pub const hyplog = @import("hyplog");
pub const BootConfig = @import("./BootConfig.zig");

pub const std_options = struct {
    pub const log_level = .debug;
    pub const logFn = logger;
};
pub const logger = hyplog.logger;

pub fn init_logger() void {
    hyplog.log_targets = .{
        hyplog.openHyperpsiLog() catch null,
        hyplog.openDevConsole() catch null,
        hyplog.openPmsg() catch null,
    } ++ .{null} ** 13;
}

pub fn check_kernel() error{KernelNotSuitable}!void {
    const utsname = std.os.uname();
    log.info("{s} {s} {s}", .{ utsname.sysname, utsname.release, utsname.version });
    if (std.mem.indexOf(u8, &utsname.version, "hyperpsi") == null) {
        log.warn("The kernel seems not to be for HyperPsi", .{});
        return error.KernelNotSuitable;
    }
}

pub var bootconfig: BootConfig = undefined;
