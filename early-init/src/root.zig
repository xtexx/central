const std = @import("std");
const log = std.log;
pub const hyplog = @import("hyplog");

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

pub fn check_kernel() void {
    const utsname = std.os.uname();
    if (std.mem.indexOf(u8, &utsname.version, "hyperpsi") == null) {
        log.warn("The kernel seems not to be for HyperPsi", .{});
    }
    log.info("{s} {s} {s}", .{ utsname.sysname, utsname.release, utsname.version });
}

pub fn strict_check_kernel() error{KernelNotSuitable}!void {
    const utsname = std.os.uname();
    if (std.mem.indexOf(u8, &utsname.version, "hyperpsi") == null) {
        log.err("The kernel seems not to be for HyperPsi: {s} {s} {s}", .{
            utsname.sysname,
            utsname.release,
            utsname.version,
        });
        return error.KernelNotSuitable;
    }
}
