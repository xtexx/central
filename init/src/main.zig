const std = @import("std");
const log = std.log;
const hypearly_init = @import("hypearly_init");

pub const std_options = hypearly_init.std_options;
pub const log_prefix = "early-init";
pub const hypearly_init_device = "samsung,klte";

pub fn main() !void {
    try hypearly_init.mount.mount_proc_sys_dev();
    hypearly_init.init_logger();
    log.info("HyperPsi samsung-klte early-init", .{});
    hypearly_init.check_kernel() catch {};

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    hypearly_init.bootconfig = hypearly_init.BootConfig.init(allocator);
    try hypearly_init.bootconfig.load();
    hypearly_init.check_bootconfig() catch {};

    try hypearly_init.setup_firmware_path();

    while (true) {}
}
