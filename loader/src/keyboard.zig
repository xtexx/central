const std = @import("std");
const log = std.log;
const File = std.fs.File;
const ioctl = std.os.linux.ioctl;

pub const c = @cImport({
    @cInclude("linux/input.h");
    @cInclude("linux/input-event-codes.h");
});
pub const InputEvent = c.input_event;

pub const KeyState = std.bit_set.ArrayBitSet(u8, c.KEY_CNT);

pub fn openInputDevices(alloc: std.mem.Allocator) ![]File {
    var dir = try std.fs.openDirAbsolute("/dev/input", .{ .iterate = true });
    defer dir.close();
    var iter = dir.iterate();
    var list = std.ArrayList(File).init(alloc);
    defer list.deinit();

    while (try iter.next()) |entry| {
        if (entry.kind == .character_device and std.mem.startsWith(u8, entry.name, "event")) {
            try list.append(try dir.openFile(entry.name, .{ .mode = .read_write }));
        }
    }
    return list.toOwnedSlice();
}

// TODO: not working
pub fn getKeyState(file: File) !KeyState {
    const keys = KeyState.initEmpty();
    const rc = @as(isize, @bitCast(ioctl(file.handle, c.EVIOCGKEY(keys.masks.len), @intFromPtr(&keys.masks))));
    if (rc <= 0) {
        log.err("Failed to call EVIOCGKEY: {}", .{rc});
        return error.IoctlError;
    }
    return keys;
}

pub fn readKeyState(inputs: []const File) !KeyState {
    var state = KeyState.initEmpty();
    for (inputs) |input| {
        defer input.close();
        const input_state = try getKeyState(input);
        state.setUnion(input_state);
    }
    return state;
}

pub fn readInputEvent(inputs: []const File, alloc: std.mem.Allocator, timeout: i32) !InputEvent {
    var pollfds = std.ArrayList(std.os.pollfd).init(alloc);
    defer pollfds.deinit();
    for (inputs) |input| {
        try pollfds.append(.{
            .fd = input.handle,
            .events = std.os.POLL.IN,
            .revents = 0,
        });
    }
    _ = try std.os.poll(pollfds.items, timeout);
    for (pollfds.items, 0..) |fd, i| {
        if (fd.revents & std.os.POLL.IN != 0) {
            return try inputs[i].reader().readStruct(InputEvent);
        }
    }
    return error.Timeout;
}
