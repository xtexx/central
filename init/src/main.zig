const std = @import("std");
const log = std.log;
const hypinit = @import("hypinit");

pub const std_options = hypinit.std_options;
pub const log_prefix = "klte-init";
pub const hypinit_device = "samsung,klte";

pub fn main() !void {
    std.time.sleep(std.time.ns_per_s * 3);
    try hypinit.prepareInit();
    try hypinit.mount.mountDev();
    hypinit.initLogger();
    log.info("HyperPsi samsung-klte early-init", .{});
    hypinit.checkKernel() catch {};
    try hypinit.mount.mountProcSysDev();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    hypinit.bootconfig = hypinit.BootConfig.init(alloc);
    defer hypinit.bootconfig.deinit();
    try hypinit.bootconfig.load();
    hypinit.checkBootConfig() catch {};

    try hypinit.setupFirmwarePath();

    try hypinit.exec(alloc, &.{ "/usr/bin/busybox", "--install", "-s", "/usr/bin" });
    try hypinit.exec(alloc, &.{ "/usr/bin/mdev", "-s" });

    try hypinit.mount.mount("none", "/", "tmpfs", 0, 0);
    log.info("Tmpfs mounted on root dir", .{});
    try hypinit.mount.autoMountLoader(alloc, null, null);
    try hypinit.exec(alloc, &.{ "/usr/bin/rm", "-rf", "/init", "/etc", "/usr", "/bin", "/lib" });

    try hypinit.execLoader(alloc);
}
