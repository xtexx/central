const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;

    const args = try init.minimal.args.toSlice(arena);
    defer arena.free(args);
    const verilator_path = args[1];
    const dep_file_path = args[2];
    const out_dir_path = args[3];
    const verilator_args = args[4..];

    var vl_args: std.ArrayList([]const u8) = .empty;
    defer vl_args.deinit(arena);
    try vl_args.append(arena, verilator_path);
    try vl_args.ensureUnusedCapacity(arena, verilator_args.len);
    for (verilator_args) |arg|
        vl_args.appendAssumeCapacity(arg);
    try vl_args.ensureUnusedCapacity(arena, 2);
    vl_args.appendAssumeCapacity("--Mdir");
    vl_args.appendAssumeCapacity(out_dir_path);

    var vl = try std.process.spawn(io, .{
        .argv = vl_args.items,
    });
    const vl_term = try vl.wait(io);
    if (!vl_term.success()) {
        std.debug.print("Verilator terminated: {f}", .{vl_term});
        return error.VerilatorFailed;
    }

    const out_dir = try std.Io.Dir.cwd().openDir(io, out_dir_path, .{});
    defer out_dir.close(io);
    const json_file = try out_dir.readFileAlloc(io, "Vtyro.json", arena, .unlimited);
    defer arena.free(json_file);
    const json = try std.json.parseFromSlice(JsonOutput, arena, json_file, .{ .ignore_unknown_fields = true });
    defer json.deinit();

    std.debug.assert(json.value.version == 1);

    {
        const dep_file = try std.Io.Dir.cwd().createFile(io, dep_file_path, .{ .truncate = true, .read = false });
        defer dep_file.close(io);
        var dep_buf: [4096]u8 = undefined;
        var dep_writer = dep_file.writerStreaming(io, &dep_buf);

        try dep_writer.interface.print("Vtyro.cpp: \\\n", .{});
        for (json.value.sources.deps) |dep_path|
            try dep_writer.interface.print("    {s} \\\n", .{dep_path});
    }

    {
        gen_group: inline for (@typeInfo(JsonOutput.Sources).@"struct".field_names) |group_name| {
            if (comptime std.mem.eql(u8, group_name, "deps")) continue :gen_group;
            const group_file_name = try arena.print("group_{s}.cpp", .{group_name});
            defer arena.free(group_file_name);

            var group_file: std.Io.Writer.Allocating = .init(arena);
            defer group_file.deinit();
            const writer = &group_file.writer;

            for (@field(json.value.sources, group_name)) |source_path| {
                const source_name = std.fs.path.basename(source_path);
                try writer.print("#include \"{s}\"\n", .{source_name});
            }

            try out_dir.writeFile(io, .{
                .sub_path = group_file_name,
                .data = group_file.written(),
            });
        }
    }
}

const JsonOutput = struct {
    version: usize,
    sources: Sources,

    const Sources = struct {
        global: []const []const u8,
        classes_slow: []const []const u8,
        classes_fast: []const []const u8,
        support_slow: []const []const u8,
        support_fast: []const []const u8,
        deps: []const []const u8,
    };
};
