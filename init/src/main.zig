const std = @import("std");
const log = std.log;
const hypinit = @import("hypinit");

pub const std_options = hypinit.std_options;
pub const log_prefix = "early-init";
pub const hypearly_init_device = "samsung,klte";

pub fn main() !void {
    std.time.sleep(std.time.ns_per_s * 3);
    try hypinit.prepareInit();
    try hypinit.mount.mountDev();
    hypinit.initLogger();
    log.info("HyperPsi samsung-klte early-init", .{});
    hypinit.checkKernel() catch {};
    // hypinit.mount.pivotEarlyInit() catch |err| {
    //     log.err("{!}", .{err});
    //     while (true) {}
    // };
    try hypinit.mount.mountProcSysDev();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    hypinit.bootconfig = hypinit.BootConfig.init(alloc);
    try hypinit.bootconfig.load();
    hypinit.checkBootConfig() catch {};

    try hypinit.setupFirmwarePath();

    // hypinit.fb.setup_fbs();
    // /dev/disk/by-partlabel/system

    while (true) {}
}
