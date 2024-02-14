const std = @import("std");
const log = std.log.scoped(.hyploader);
const hyplog = @import("hyplog");
const init = @import("hypinit");

pub const BootConfig = init.BootConfig;
pub const mount = init.mount;
pub const std_options = init.std_options;
pub const initLogger = init.initLogger;
pub const exec = init.exec;
pub var bootconfig: BootConfig = undefined;

pub fn prepareLoader() !void {
    try std.os.chdir("/loader");
}
