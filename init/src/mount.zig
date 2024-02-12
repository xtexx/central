const std = @import("std");
const hyplog = @import("hyplog");
const log = std.log.scoped(.hypinit_mount);

pub const MS = std.os.linux.MS;

pub fn mount(source: [:0]const u8, target: [:0]const u8, fstype: ?[*:0]const u8, flags: u32, data: usize) error{MountFailure}!void {
    std.fs.makeDirAbsolute(@as([]const u8, target)) catch {};
    const rc = std.os.linux.mount(source.ptr, target.ptr, fstype, flags, data);
    if (std.os.linux.getErrno(rc) != .SUCCESS) {
        const rc1 = std.os.linux.mount(source.ptr, target.ptr, fstype, flags | MS.REMOUNT, data);
        if (std.os.linux.getErrno(rc1) != .SUCCESS) {
            log.err("Failed to mount {s} to {s}, errno {}, remount {}", .{
                source,
                target,
                @as(
                    isize,
                    @bitCast(rc),
                ),
                @as(isize, @bitCast(rc1)),
            });
            return error.MountFailure;
        }
    }
}

pub fn mountFn(comptime source: [:0]const u8, comptime target: [:0]const u8, comptime fstype: ?[*:0]const u8, comptime flags: u32, comptime data: usize) fn () error{MountFailure}!void {
    return struct {
        pub fn function() error{MountFailure}!void {
            try mount(source, target, fstype, flags, data);
        }
    }.function;
}

pub const mountProc = mountFn("proc", "/proc", "proc", MS.NODEV | MS.NOEXEC | MS.NOSUID, 0);
pub const mountSys = mountFn("sysfs", "/sys", "sysfs", MS.NODEV | MS.NOEXEC | MS.NOSUID, 0);
pub const mountDev = mountFn("dev", "/dev", "devtmpfs", MS.NOSUID, 0);
pub const mountTmp = mountFn("tmpfs", "/tmp", "tmpfs", MS.NODEV | MS.NOSUID, 0);
pub const mountConfig = mountFn("configfs", "/config", "configfs", MS.NODEV | MS.NOEXEC | MS.NOSUID, 0);
pub const mountDevpts = mountFn("devpts", "/dev/pts", "devpts", MS.NODEV | MS.NOEXEC | MS.NOSUID, 0);

pub fn mountProcSysDev() !void {
    try mountProc();
    try mountSys();
    try mountDev();
    try mountTmp();
    mountConfig() catch {};
    mountDevpts() catch {};
}

pub fn loadFromPartition() !void {
    switch (std.os.linux.getErrno(std.os.linux.umount2("/dev", std.os.linux.MNT.DETACH))) {
        .SUCCESS => {},
        else => |err| {
            log.err("Failed to umount devtmpfs: errno {}", .{err});
            return std.os.unexpectedErrno(err);
        },
    }
    try std.fs.deleteDirAbsolute("/dev");
    log.debug("pivot_root: dev umounted", .{});

    const loader_dir = "/loader";
    try std.fs.makeDirAbsolute(loader_dir);
    log.debug("pivot_root: new root prepared", .{});

    // var rt = try std.fs.openDirAbsolute("/", .{ .iterate = true });
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // const alloc = gpa.allocator();
    // var iter = try rt.walk(alloc);
    // while (try iter.next()) |dir| {
    //     log.info("{!} {s}", .{ dir.kind, dir.path });
    // }
    // rt.close();
}
