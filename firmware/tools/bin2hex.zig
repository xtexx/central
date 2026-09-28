const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;

    const args = try init.minimal.args.toSlice(arena);
    const bin_path = args[1];
    const hex_path = args[2];

    const bin_file = try std.Io.Dir.cwd().openFile(io, bin_path, .{ .mode = .read_only });
    defer bin_file.close(io);
    const hex_file = try std.Io.Dir.cwd().createFile(io, hex_path, .{ .truncate = true, .read = false });
    defer hex_file.close(io);

    var bin_reader = bin_file.readerStreaming(io, &.{});
    const bin_data = try bin_reader.interface.allocRemaining(arena, .unlimited);
    std.debug.assert(bin_data.len % 8 == 0);

    var hex_buf: [4096]u8 = undefined;
    var hex_writer = hex_file.writerStreaming(io, &hex_buf);

    for (0..bin_data.len / 8) |i| {
        const val = std.mem.littleToNative(u64, @bitCast(bin_data[i * 8 ..][0..8].*));
        try hex_writer.interface.printInt(
            val,
            16,
            .lower,
            .{ .alignment = .right, .fill = '0', .width = 16 },
        );
        try hex_writer.interface.writeAll("\n");
    }
}
