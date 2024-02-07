const std = @import("std");
pub const hyplog = @import("hyplog");

pub const std_options = struct {
    pub const log_level = .debug;
    pub const logFn = logger;
};
pub const logger = hyplog.logger;

pub fn init_logger() !void {
    hyplog.log_targets = []?hyplog.File{
        hyplog.openHyperpsiLog() orelse null,
        hyplog.openDevConsole() orelse null,
        hyplog.openPmsg() orelse null,
    };
}
