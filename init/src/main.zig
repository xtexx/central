const std = @import("std");
const log = std.log;
const hypinit = @import("hypinit");

pub const std_options = hypinit.std_options;
pub const log_prefix = "early-init";
pub const hypearly_init_device = "samsung,klte";

pub fn main() !void {
    try hypinit.mount.mount_proc_sys_dev();
    hypinit.init_logger();
    log.info("HyperPsi samsung-klte early-init", .{});
    hypinit.check_kernel() catch {};

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    hypinit.bootconfig = hypinit.BootConfig.init(allocator);
    try hypinit.bootconfig.load();
    hypinit.check_bootconfig() catch {};

    try hypinit.setup_firmware_path();

    while (true) {}
}
