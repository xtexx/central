const std = @import("std");
const log = std.log;
const hsdt = @import("./hsdt.zig");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const args = try init.minimal.args.toSlice(gpa);
    defer gpa.free(args);
    if (args.len == 1) {
        log.err("usage: {s} <file>", .{args[0]});
        return;
    } else if (args.len != 2) {
        log.err("too many arguments: {s}", .{args[2]});
        return;
    }
    const path = args[1];
    log.info("Reading HSDT file from: {s}", .{path});
    const basename = std.fs.path.basename(path);

    const dtb_buffer = try gpa.alloc(u8, 1024);
    defer gpa.free(dtb_buffer);
    const writer_buffer = try gpa.alloc(u8, std.compress.flate.max_window_len);
    defer gpa.free(writer_buffer);

    const file = try std.Io.Dir.cwd().openFile(io, path, .{ .mode = .read_only });
    defer file.close(io);
    var file_reader = file.reader(io, dtb_buffer);

    const offset: usize = if (try file_reader.interface.peekInt(u32, .little) != hsdt.DT_TABLE_MAGIC)
        // for DTS dumped from system update package (UPDATE.APP file)
        // there are 4096 bytes of junk at the head of file
        4096
    else
        // for DTS dumped from Huawei's Android device
        // /dev/block/bootdevice/by-name/dts
        // the table is at the beginning of the HSDT file
        0;
    if (offset == 4096) {
        log.info("Detected DTS partition image dumped from system update package", .{});
    } else {
        log.info("Detected DTS partition image dumped from device", .{});
    }

    try file_reader.interface.discardAll(offset);
    const header = try hsdt.DtTableHeader.read(&file_reader.interface);
    log.info("Totally {} DTB entries", .{header.entry_count});
    const entries = try gpa.alloc(hsdt.DtEntry, header.entry_count);
    defer gpa.free(entries);
    for (entries) |*entry|
        entry.* = try hsdt.DtEntry.read(&file_reader.interface);
    for (entries) |entry| {
        const board_id_str = try std.fmt.allocPrint(gpa, "<0x{x:02} 0x{x:02} 0x{x:02} 0x{x:02}>", .{
            entry.board_id[0], entry.board_id[1],
            entry.board_id[2], entry.board_id[3],
        });
        defer gpa.free(board_id_str);
        const filename = try std.fmt.allocPrint(gpa, "{s}_{x:02}{x:02}{x:02}{x:02}", .{
            basename,          entry.board_id[0],
            entry.board_id[1], entry.board_id[2],
            entry.board_id[3],
        });
        defer gpa.free(filename);
        if (entry.vrl) |vrl| {
            log.info("Found DTB for {s}, DTB at 0x{x} ({} bytes), VRL at 0x{x} ({} bytes)", .{
                board_id_str,
                entry.dtb.offset,
                entry.dtb.len,
                vrl.offset,
                vrl.len,
            });
        } else {
            log.info("Found DTB for {s}, DTB at 0x{x} ({} bytes), no VRL", .{
                board_id_str, entry.dtb.offset, entry.dtb.len,
            });
        }

        {
            const dtb_gz_path = try std.fmt.allocPrint(gpa, "{s}.dtb.gz", .{filename});
            defer gpa.free(dtb_gz_path);
            const dtb_gz_file = try std.Io.Dir.cwd().createFile(io, dtb_gz_path, .{
                .read = true,
                .lock = .exclusive,
            });
            defer dtb_gz_file.close(io);
            {
                var dtb_gz_writer = dtb_gz_file.writer(io, dtb_buffer);
                try file_reader.seekTo(offset + entry.dtb.offset);
                try file_reader.interface.streamExact64(&dtb_gz_writer.interface, entry.dtb.len);
                try dtb_gz_writer.interface.flush();
            }

            // gzip decompress
            const dtb_path = try std.fmt.allocPrint(gpa, "{s}.dtb", .{filename});
            defer gpa.free(dtb_path);
            const dtb_file = try std.Io.Dir.cwd().createFile(io, dtb_path, .{ .lock = .exclusive });
            defer dtb_file.close(io);

            var dtb_gz_reader = dtb_gz_file.reader(io, dtb_buffer);
            try dtb_gz_reader.seekTo(0);
            var decompressor: std.compress.flate.Decompress = .init(&dtb_gz_reader.interface, .gzip, &.{});

            var dtb_writer = dtb_file.writerStreaming(io, writer_buffer);
            _ = try decompressor.reader.streamRemaining(&dtb_writer.interface);
        }

        if (entry.vrl) |vrl| {
            const vrl_path = try std.fmt.allocPrint(gpa, "{s}_vrl.bin", .{filename});
            defer gpa.free(vrl_path);
            const vrl_file = try std.Io.Dir.cwd().createFile(io, vrl_path, .{ .lock = .exclusive });
            defer vrl_file.close(io);

            var vrl_writer = vrl_file.writer(io, dtb_buffer);
            try file_reader.seekTo(offset + vrl.offset);
            try file_reader.interface.streamExact64(&vrl_writer.interface, vrl.len);
            try vrl_writer.interface.flush();
        }
    }
}

pub const std_options: std.Options = .{ .log_level = .info };
