const std = @import("std");
const File = std.fs.File;

pub const std_options = struct {
    pub const log_level = .debug;
    pub const logFn = logger;
};

var logger_mutex = std.Thread.Mutex{};
pub var log_targets = [16]?File;

pub fn logger(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const prefix = "[" ++ comptime level.asText() ++ "] " ++ @tagName(scope) ++ ": ";
    logger_mutex.lock();
    defer logger_mutex.unlock();

    // write to stderr
    const stderr = std.io.getStdErr().writer();
    nosuspend stderr.print(prefix ++ format ++ "\n", args) catch return;

    // write to log targets
    for (log_targets) |target| {
        const writer = (target orelse continue).writer();
        writer.print(prefix ++ format ++ "\n", args);
    }
}

pub fn openDevConsole() File.OpenError!File {
    std.fs.openFileAbsolute("/dev/console", .{ .mode = .write_only });
}

pub fn openPmsg() File.OpenError!File {
    std.fs.openFileAbsolute("/dev/pmsg0", .{ .mode = .write_only });
}

pub fn openHyperpsiLog() File.OpenError!File {
    std.fs.createFileAbsolute("/hyperpsi_log", .{ .truncate = false, .read = false, .mode = 0o660 });
}
