const std = @import("std");
const mkdir = std.fs.makeDirAbsolute;
const MS = std.os.linux.MS;

pub fn mount(source: [:0]const u8, target: [:0]const u8, fstype: ?[*:0]const u8, flags: u32, data: usize) error{MountFailure}!void {
    std.fs.makeDirAbsolute(@as([]const u8, target)) catch {};
    const rc = std.os.linux.mount(source.ptr, target.ptr, fstype, flags, data);
    if (std.os.linux.getErrno(rc) != .SUCCESS) {
        std.log.err("Failed to mount {s} to {s}, errno {}", .{ source, target, @as(isize, @bitCast(rc)) });
        return error.MountFailure;
    }
}

pub fn mount_proc_sys_dev() !void {
    try mount("proc", "/proc", "proc", MS.NODEV | MS.NOEXEC | MS.NOSUID, 0);
    try mount("sysfs", "/sys", "sysfs", MS.NODEV | MS.NOEXEC | MS.NOSUID, 0);
    try mount("dev", "/dev", "devtmpfs", MS.NOSUID | MS.REMOUNT, @intFromPtr("mode=0755"));
    try mount("tmpfs", "/tmp", "tmpfs", MS.NODEV | MS.NOSUID, @intFromPtr("mode=0755"));
    mount("configfs", "/config", "configfs", MS.NODEV | MS.NOEXEC | MS.NOSUID, 0) catch {};
    mount("devpts", "/dev/pts", "devpts", MS.NODEV | MS.NOEXEC | MS.NOSUID, @intFromPtr("mode=600")) catch {};
}
