const std = @import("std");
const log = std.log;
const hyploader = @import("hyploader");

pub const recovery = @import("./recovery.zig");

pub const std_options = hyploader.std_options;
pub const log_prefix = "klte-loader";
pub const hypinit_device = "samsung,klte";

pub fn main() !void {
    try hyploader.prepareLoader();
    try hyploader.mount.mountProcSysDev();
    hyploader.initLogger();
    log.info("HyperPsi samsung-klte loader", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    hyploader.bootconfig = hyploader.BootConfig.init(alloc);
    defer hyploader.bootconfig.deinit();
    try hyploader.bootconfig.load();

    if (try shouldEnterLoaderRecovery(alloc)) {
        try hyploader.recovery.startLoaderRecovery(alloc);
    }
    while (true) {}
}

pub fn shouldEnterLoaderRecovery(alloc: std.mem.Allocator) !bool {
    const kbd = hyploader.keyboard;

    const inputs = try kbd.openInputDevices(alloc);
    defer alloc.free(inputs);
    defer for (inputs) |input| input.close();

    // const state = try kbd.readKeyState(inputs);
    // return state.isSet(kbd.c.KEY_VOLUMEDOWN) and state.isSet(kbd.c.KEY_HOMEPAGE);
    if (kbd.readInputEvent(inputs, alloc, 200) catch null) |ev| {
        if (ev.type == kbd.c.EV_KEY and ev.value == 1 and ev.code == kbd.c.KEY_HOMEPAGE) {
            return true;
        }
    }
    return false;
}
