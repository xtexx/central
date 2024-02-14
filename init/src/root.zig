const root = @import("root");
const std = @import("std");
const log = std.log.scoped(.hypinit);
pub const hyplog = @import("hyplog");
pub const BootConfig = @import("./BootConfig.zig");
pub const mount = @import("./mount.zig");
pub const loopdev = @import("./loopdev.zig");

pub const std_options: std.Options = .{
    .log_level = .debug,
    .logFn = logger,
};
pub const logger = hyplog.logger;
pub const device = root.hypinit_device;

pub fn prepareInit() !void {
    try std.os.chdir("/");
}

pub fn initLogger() void {
    hyplog.closeTargets();
    hyplog.log_targets[0] = hyplog.openHyperpsiLog() catch null;
    hyplog.log_targets[1] = hyplog.openPmsg() catch null;
    log.info("Logger initialized", .{});
}

pub fn checkKernel() error{KernelNotSuitable}!void {
    const utsname = std.os.uname();
    std.log.info("{s} {s} {s}", .{ utsname.sysname, utsname.release, utsname.version });
    if (std.mem.indexOf(u8, &utsname.release, "hyperpsi") == null) {
        log.warn("The kernel seems not to be for HyperPsi", .{});
        return error.KernelNotSuitable;
    }
}

pub var bootconfig: BootConfig = undefined;

pub fn checkBootConfig() !void {
    const config_device = bootconfig.get("hyperpsi.device") orelse "";
    if (!std.mem.eql(u8, config_device, device)) {
        log.err("Not supported hyperpsi.device value (\"{s}\"), booting may fail", .{config_device});
    }
    if (bootconfig.get("hyperpsi.kernel_release")) |kernel| {
        const utsname = std.os.uname();
        if (!std.mem.eql(u8, &utsname.release, kernel)) {
            std.log.err("Kernel requirement not meet", .{});
        }
    }
}

pub fn setupFirmwarePath() !void {
    try setFirmwarePath(bootconfig.get("hyperpsi.firmware_path") orelse "/lib/firmware/hyperpsi");
}

pub fn setFirmwarePath(path: []const u8) !void {
    std.fs.makeDirAbsolute(path) catch {};
    const file = std.fs.openFileAbsolute("/sys/module/firmware_class/parameters/path", .{ .mode = .write_only }) catch |err| switch (err) {
        std.fs.File.OpenError.FileNotFound => return,
        else => return err,
    };
    defer file.close();
    try file.writeAll(path);
    log.info("Firmware path set to {s}", .{path});
}

pub fn exec(alloc: std.mem.Allocator, argv: []const []const u8) !void {
    const result = try std.process.Child.run(.{
        .allocator = alloc,
        .argv = argv,
    });
    defer alloc.free(result.stdout);
    defer alloc.free(result.stderr);
    log.info("{s}: exit code: {!}, stdout: {s}, stderr: {s}", .{ argv[0], result.term, result.stdout, result.stderr });
    switch (result.term) {
        .Exited => |status| {
            if (status != 0) {
                return error.ChildProcessNonZeroExit;
            }
        },
        else => return error.ChildProcessError,
    }
}

pub fn execLoader(alloc: std.mem.Allocator) !void {
    try std.os.chdir("/loader");
    return std.process.execv(alloc, &.{"/loader/init"});
}
