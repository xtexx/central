const root = @import("root");
const std = @import("std");
pub const log = @import("hyplog");
pub const BootConfig = @import("./BootConfig.zig");
pub const mount = @import("./mount.zig");

pub const std_options: std.Options = .{
    .log_level = .debug,
    .logFn = logger,
};
pub const logger = log.logger;
pub const device = root.hypearly_init_device;

pub fn init_logger() void {
    log.log_targets[0] = log.openHyperpsiLog() catch null;
    log.log_targets[1] = log.openPmsg() catch null;
    std.log.info("Logger initialized", .{});
}

pub fn check_kernel() error{KernelNotSuitable}!void {
    const utsname = std.os.uname();
    std.log.info("{s} {s} {s}", .{ utsname.sysname, utsname.release, utsname.version });
    if (std.mem.indexOf(u8, &utsname.release, "hyperpsi") == null) {
        std.log.warn("The kernel seems not to be for HyperPsi", .{});
        return error.KernelNotSuitable;
    }
}

pub var bootconfig: BootConfig = undefined;

pub fn check_bootconfig() !void {
    const config_device = bootconfig.get("hyperpsi.device") orelse "";
    if (!std.mem.eql(u8, config_device, device)) {
        std.log.err("Not supported hyperpsi.device value, booting may fail", .{});
    }
    if (bootconfig.get("hyperpsi.kernel_release")) |kernel| {
        const utsname = std.os.uname();
        if (!std.mem.eql(u8, &utsname.release, kernel)) {
            std.log.err("Kernel requirement not meet", .{});
        }
    }
}

pub fn setup_firmware_path() !void {
    try set_firmware_path("/lib/firmware/hyperpsi");
}

pub fn set_firmware_path(path: []const u8) !void {
    std.fs.makeDirAbsolute(path) catch {};
    const file = std.fs.openFileAbsolute("/sys/module/firmware_class/parameters/path", .{ .mode = .write_only }) catch |err| switch (err) {
        std.fs.File.OpenError.FileNotFound => return,
        else => return err,
    };
    defer file.close();
    try file.writeAll(path);
}
