const std = @import("std");
const log = std.log;
const hypinit = @import("hypinit");

pub const std_options = hypinit.std_options;
pub const log_prefix = "klte-init";
pub const hypinit_device = "samsung,klte";

pub fn main() !void {
    std.time.sleep(std.time.ns_per_s * 3);
    try hypinit.prepareInit();
    try hypinit.mount.mountDev();
    hypinit.initLogger();
    log.info("HyperPsi samsung-klte early-init", .{});
    hypinit.checkKernel() catch {};
    // try hypinit.mount.mountProcSysDev();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    hypinit.bootconfig = hypinit.BootConfig.init(alloc);
    try hypinit.bootconfig.load();
    hypinit.checkBootConfig() catch {};

    try hypinit.setupFirmwarePath();

    try hypinit.mount.mount("none", "/", "tmpfs", 0, 0);
    log.info("Tmpfs mounted on root dir", .{});

    {
        var dir = try std.fs.openDirAbsolute("/", .{ .iterate = true });
        defer dir.close();
        var walk = try dir.walk(alloc);
        defer walk.deinit();
        while (try walk.next()) |ent| {
            if (std.mem.startsWith(u8, ent.path, "proc/")) {
                continue;
            }
            if (std.mem.startsWith(u8, ent.path, "sys/")) {
                continue;
            }
            log.info("DIR {s} {!}", .{ ent.path, ent.kind });
        }
    }

    // if system partition is a SquashFS image, we load it to tmpfs first
    // later 2-stage loader will create ext on system partition
    if (try getSystemPartSquashFSSize()) |syssize| {
        const syspart = hypinit.mount.getSystemPart();
        log.info("sysp {s} syss {}", .{ syspart, syssize });
        // {
        //     log.info("Copying {} bytes to /loader.sqfs", .{syssize});
        //     const sysfile = try std.fs.openFileAbsolute(syspart, .{ .mode = .read_only, .lock = .exclusive });
        //     defer sysfile.close();
        //     const tmpfile = try std.fs.createFileAbsolute("/loader.sqfs", .{ .exclusive = true, .lock = .exclusive, .mode = 0o600 });
        //     defer tmpfile.close();
        //     try tmpfile.writeFileAll(sysfile, .{ .in_len = syssize });
        //     log.info("Copied system partition to /loader.sqfs", .{});
        // }
        // try hypinit.mount.mount("/loader.sqfs", "/loader", "squashfs", hypinit.mount.MS.RDONLY, 0);
        log.info("Mounted loader.sqfs", .{});
    } else {
        // try hypinit.mount.autoMountSystemPart(null, null);
    }

    {
        var dir = try std.fs.openDirAbsolute("/", .{ .iterate = true });
        defer dir.close();
        var walk = try dir.walk(alloc);
        defer walk.deinit();
        while (try walk.next()) |ent| {
            if (std.mem.startsWith(u8, ent.path, "dev/")) {
                continue;
            }
            log.info("DIR {s} {!}", .{ ent.path, ent.kind });
        }
    }

    while (true) {}
}

fn getSystemPartSquashFSSize() !?usize {
    const file = try std.fs.openFileAbsolute(hypinit.mount.getSystemPart(), .{ .mode = .read_only, .lock = .exclusive });
    defer file.close();
    var magic: [4]u8 = undefined;
    if (try file.readAll(&magic) != 4) {
        return error.SystemPartitionTooSmall;
    }
    if (std.mem.eql(u8, &magic, &.{ 0x68, 0x73, 0x71, 0x73 })) {
        const reader = file.reader();
        try file.seekTo(12);
        const block_size = try reader.readInt(u32, .little);
        try file.seekTo(40);
        const bytes_used = try reader.readInt(u32, .little);
        return bytes_used + (block_size - (bytes_used % block_size));
    } else {
        return null;
    }
}
