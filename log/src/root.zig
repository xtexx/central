const root = @import("root");
const std = @import("std");
const File = std.fs.File;

const global_prefix = root.log_prefix;

pub const std_options = struct {
    pub const log_level = .debug;
    pub const logFn = logger;
};

var logger_mutex = std.Thread.Mutex{};
pub var log_targets: [16]?File = [_]?File{null} ** 16;
// TODO: Add sync open to zig
pub var sync_log: bool = true;

pub fn logger(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const scopeTag = switch (scope) {
        .default => "",
        else => " " ++ @tagName(scope) ++ ":",
    };
    const prefix = "[" ++ global_prefix ++ "] " ++ "[" ++ comptime level.asText() ++ "]" ++ scopeTag ++ " ";
    logger_mutex.lock();
    defer logger_mutex.unlock();

    // write to stdout
    const stdout = std.io.getStdOut().writer();
    nosuspend stdout.print(prefix ++ format ++ "\n", args) catch {};

    // write to log targets
    for (log_targets) |target| {
        if (target) |file| {
            const writer = file.writer();
            nosuspend writer.print(prefix ++ format ++ "\n", args) catch {};
            if (sync_log) {
                file.sync() catch {};
            }
        }
    }
}

pub fn openDevConsole() File.OpenError!File {
    return std.fs.openFileAbsolute("/dev/console", .{ .mode = .write_only });
}

pub fn openPmsg() File.OpenError!File {
    return std.fs.openFileAbsolute("/dev/pmsg0", .{ .mode = .write_only });
}

pub fn openHyperpsiLog() File.OpenError!File {
    return std.fs.createFileAbsolute("/hyperpsi_log", .{ .truncate = false, .read = false, .mode = 0o660 });
}
