const std = @import("std");

pub const MS = std.os.linux.MS;

pub fn mount(source: [:0]const u8, target: [:0]const u8, fstype: ?[*:0]const u8, flags: u32, data: usize) error{MountFailure}!void {
    std.fs.makeDirAbsolute(@as([]const u8, target)) catch {};
    const rc = std.os.linux.mount(source.ptr, target.ptr, fstype, flags, data);
    if (std.os.linux.getErrno(rc) != .SUCCESS) {
        const rc1 = std.os.linux.mount(source.ptr, target.ptr, fstype, flags | MS.REMOUNT, data);
        if (std.os.linux.getErrno(rc1) != .SUCCESS) {
            std.log.err("Failed to mount {s} to {s}, errno {}, remount {}", .{
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

pub fn mount_proc_sys_dev() !void {
    try mount("proc", "/proc", "proc", MS.NODEV | MS.NOEXEC | MS.NOSUID, 0);
    try mount("sysfs", "/sys", "sysfs", MS.NODEV | MS.NOEXEC | MS.NOSUID, 0);
    try mount("dev", "/dev", "devtmpfs", MS.NOSUID, 0);
    try mount("tmpfs", "/tmp", "tmpfs", MS.NODEV | MS.NOSUID, 0);
    mount("configfs", "/config", "configfs", MS.NODEV | MS.NOEXEC | MS.NOSUID, 0) catch {};
    mount("devpts", "/dev/pts", "devpts", MS.NODEV | MS.NOEXEC | MS.NOSUID, @intFromPtr("mode=600")) catch {};
}
