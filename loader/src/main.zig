const std = @import("std");
const log = std.log;
const hyploader = @import("hyploader");

pub const std_options = hyploader.std_options;
pub const log_prefix = "klte-loader";
pub const hypinit_device = "samsung,klte";

pub fn main() !void {
    try hyploader.prepareLoader();
    try hyploader.mount.mountDev();
    hyploader.initLogger();
    log.info("HyperPsi samsung-klte loader", .{});
    hyploader.checkKernel() catch {};
    try hyploader.mount.mountProcSysDev();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    hyploader.bootconfig = hyploader.BootConfig.init(alloc);
    defer hyploader.bootconfig.deinit();
    try hyploader.bootconfig.load();

    // try hyploader.exec(alloc, &.{ "/usr/bin/busybox", "--install", "-s", "/usr/bin" });

    while (true) {}
}
