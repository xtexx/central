const std = @import("std");
const mem = std.mem;
const http = std.http;

pub fn main(init: std.process.Init) !void {
    const arena = init.gpa;
    const io = init.io;

    var body: std.Io.Writer.Allocating = .init(arena);
    defer body.deinit();
    try body.ensureUnusedCapacity(64 * 1024);

    var args = try init.minimal.args.iterateAllocator(arena);
    _ = args.skip();
    if (args.next()) |file_path| {
        std.debug.print("Loading elf.h from {s} ...\n", .{file_path});
        const elf_h = try std.Io.Dir.cwd().openFile(io, file_path, .{ .mode = .read_only });
        defer elf_h.close(io);
        var elf_h_reader = elf_h.reader(io, &.{});
        _ = try elf_h_reader.interface.streamRemaining(&body.writer);
    } else {
        std.debug.print("Fetching musl elf.h ...\n", .{});
        var client: http.Client = .{ .allocator = arena, .io = io };
        defer client.deinit();
        const res = try client.fetch(.{
            .location = .{ .url = "https://git.musl-libc.org/cgit/musl/plain/include/elf.h" },
            .method = .GET,
            .extra_headers = &.{.{ .name = "User-Agent", .value = "gen-elf-relocs-enum.zig" }},
            .response_writer = &body.writer,
        });
        std.debug.assert(res.status == .ok);
    }

    std.debug.print("Generating elf.zig ...\n", .{});

    var stdout_buffer: [4096]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    var output = &stdout_writer.interface;

    var lines = mem.splitScalar(u8, body.written(), '\n');
    var last_arch: ?[]const u8 = null;
    while (lines.next()) |line| {
        var tokens = mem.tokenizeAny(u8, line, " \t");
        if (!mem.eql(u8, tokens.next() orelse continue, "#define")) continue;
        const def_name = tokens.next() orelse continue;
        if (!mem.startsWith(u8, def_name, "R_")) continue;
        const value = tokens.next() orelse continue;

        const arch_off = mem.indexOfScalar(u8, def_name[2..], '_') orelse continue;
        const arch = def_name[2..][0..arch_off];
        const reloc_name = def_name[2 + arch_off + 1 ..];
        if (last_arch) |last_arch_name| {
            if (!mem.eql(u8, last_arch_name, arch)) {
                last_arch = arch;
                try output.print("    _,\n}};\n\npub const R_{s} = enum(u32) {{\n", .{arch});
            }
        } else {
            last_arch = arch;
            try output.print("pub const R_{s} = enum(u32) {{\n", .{arch});
        }
        try output.print("    {f} = {s},\n", .{ std.zig.fmtId(reloc_name), value });
    }

    try output.print("    _,\n}};\n", .{});
    try output.flush();
}
