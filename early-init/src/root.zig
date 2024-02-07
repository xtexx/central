const std = @import("std");
pub const hyplog = @import("hyplog");

pub const std_options = struct {
    pub const log_level = .debug;
    pub const logFn = logger;
};
pub const logger = hyplog.logger;

pub fn init_logger() void {
    hyplog.log_targets = .{
        hyplog.openHyperpsiLog() catch null,
        hyplog.openDevConsole() catch null,
        hyplog.openPmsg() catch null,
    } ++ .{null} ** 13;
}
