const std = @import("std");
const hypinit = @import("./root.zig");
const log = std.log.scoped(.hypinit_loopdev);

pub const c = @cImport(@cInclude("linux/loop.h"));
const ioctl = std.os.linux.ioctl;
const File = std.fs.File;

const LOOP_CONTORL = "/dev/loop-control";

pub fn openLoopControl() !File {
    return try std.fs.openFileAbsolute(LOOP_CONTORL, .{ .mode = .read_write });
}

pub fn getFreeLoop() !usize {
    const ctl = try openLoopControl();
    defer ctl.close();
    const nr = ioctl(ctl.handle, c.LOOP_CTL_GET_FREE, 0);
    if (@as(isize, @bitCast(nr)) == -1) {
        return error.NoFreeLoopDevice;
    }
    return nr;
}

/// Caller owns memory
pub fn getLoopDevicePath(alloc: std.mem.Allocator, nr: usize) ![]u8 {
    return try std.fmt.allocPrint(alloc, "/dev/loop{}", .{nr});
}

pub fn configure(device: File, backing: []const u8, flags: u32) !void {
    const file = try std.fs.openFileAbsolute(backing, .{ .mode = .read_write });

    var lcfg = std.mem.zeroes(c.struct_loop_config);
    lcfg.fd = @as(usize, @bitCast(file.handle));
    @memcpy(&lcfg.info.lo_file_name, backing[0..@min(64, backing.len)].ptr);
    lcfg.info.lo_offset = 0;
    lcfg.info.lo_sizelimit = (try file.stat()).size;
    lcfg.info.lo_flags = flags;
    const rc = ioctl(device.handle, c.LOOP_CONFIGURE, @as(usize, @intFromPtr(&lcfg)));
    if (rc != 0) {
        log.err("Failed to configure loop device: {}", .{rc});
    } else {
        log.info("Configured loop device: backing: {s}, flags: {}", .{ backing, flags });
    }
}
