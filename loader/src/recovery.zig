const std = @import("std");
const log = std.log.scoped(.hyploader_rec);
const keyboard = @import("./keyboard.zig");

const device = @import("root").recovery;

pub const MenuOption = struct {
    text: []const u8,
    function: *const (fn (MenuFnArgs) ?[]const u8),
};

pub const MenuFnArgs = struct {
    alloc: std.mem.Allocator,
    inputs: []const std.fs.File,
};

pub const menu_options: []const MenuOption = &.{
    .{
        .text = "Boot",
        .function = &boot,
    },
    .{
        .text = "Show pstore",
        .function = &show_pstore,
    },
    .{
        .text = "Power Off",
        .function = &poweroff,
    },
    .{
        .text = "Reboot",
        .function = &reboot,
    },
};

pub fn startLoaderRecovery(alloc: std.mem.Allocator) !void {
    log.info("Starting loader recovery", .{});

    const inputs = try keyboard.openInputDevices(alloc);
    defer alloc.free(inputs);
    defer for (inputs) |input| input.close();

    const stdout = std.io.getStdOut();

    var selection: u32 = 0;
    while (true) {
        const event: ?keyboard.InputEvent = keyboard.readInputEvent(inputs, alloc, 1000) catch null;
        if (event) |ev| {
            if (ev.type == keyboard.c.EV_KEY and ev.value == 1) {
                switch (ev.code) {
                    keyboard.c.KEY_VOLUMEUP => {
                        const opt = menu_options[selection];
                        const args: MenuFnArgs = .{
                            .alloc = alloc,
                            .inputs = inputs,
                        };
                        log.info("Function: {s}", .{opt.text});
                        if (opt.function(args)) |err| {
                            if (std.mem.eql(u8, err, "BOOT")) return;
                            log.err("Function {s} error: {s}", .{ opt.text, err });
                        }
                        log.info("Press Volume Down to continue.", .{});
                        while (keyboard.readInputEvent(inputs, alloc, -1) catch null) |ev1| {
                            if (ev1.type == keyboard.c.EV_KEY and ev1.value == keyboard.c.KEY_VOLUMEDOWN and ev1.value == 1) {
                                break;
                            }
                        }
                    },
                    keyboard.c.KEY_VOLUMEDOWN => {
                        selection = (selection + 1) % menu_options.len;
                    },
                    else => {},
                }
                // clear screen
                try stdout.writeAll(&.{ 0x1B, 0x9B, 0x32, 0x4A, 0x1B, 0x9B, 0x48 });
                for (0..3) |_| log.info("====================", .{});
                log.info("HyperPsi Loader Recovery", .{});

                log.info("> {s}", .{menu_options[selection].text});
            }
        }
    }
}

fn boot(_: MenuFnArgs) ?[]const u8 {
    std.io.getStdOut().writeAll(&.{ 0x1B, 0x9B, 0x32, 0x4A, 0x1B, 0x9B, 0x48 }) catch {};
    return "BOOT";
}

fn show_pstore(args: MenuFnArgs) ?[]const u8 {
    var dir = std.fs.openDirAbsolute("/sys/fs/pstore", .{ .iterate = true }) catch |err| return @errorName(err);
    defer dir.close();
    var iter = dir.iterate();
    var files = std.ArrayList([]const u8).init(args.alloc);
    defer files.deinit();
    while (iter.next() catch |err| return @errorName(err)) |ent| {
        files.append(args.alloc.dupe(u8, ent.name) catch |err| return @errorName(err)) catch |err| return @errorName(err);
    }
    defer for (files.items) |f| args.alloc.free(f);

    var selection: u32 = 0;
    while (true) {
        const event = keyboard.readInputEvent(args.inputs, args.alloc, -1) catch null;
        if (event) |ev| {
            if (ev.type == keyboard.c.EV_KEY and ev.value == 1) {
                switch (ev.code) {
                    keyboard.c.KEY_VOLUMEUP => {
                        const filename = files.items[selection];
                        const file = dir.openFile(filename, .{ .mode = .read_only }) catch |err| return @errorName(err);
                        log.info("Reading: {s}", .{filename});
                        log.info("Press Volume Down to continue", .{});
                        while (keyboard.readInputEvent(args.inputs, args.alloc, -1) catch null) |ev1| {
                            if (ev1.type == keyboard.c.EV_KEY and ev1.value == keyboard.c.KEY_VOLUMEDOWN and ev1.value == 1) {
                                for (0..25) |_| {
                                    const line = file.reader().readUntilDelimiterOrEofAlloc(args.alloc, '\n', 1024) catch |err| return @errorName(err);
                                    if (line) |l| {
                                        const stdout = std.io.getStdOut();
                                        stdout.writeAll(l) catch |err| return @errorName(err);
                                        stdout.writeAll("\n") catch |err| return @errorName(err);
                                    } else {
                                        return null;
                                    }
                                }
                            }
                        }
                    },
                    keyboard.c.KEY_VOLUMEDOWN => {
                        selection = (selection + 1) % files.items.len;
                    },
                    else => {},
                }
            }
        }
    }
    return null;
}

fn poweroff(_: MenuFnArgs) ?[]const u8 {
    std.os.sync();
    std.os.reboot(.POWER_OFF) catch |err| return @errorName(err);
    return null;
}

fn reboot(_: MenuFnArgs) ?[]const u8 {
    std.os.sync();
    std.os.reboot(.RESTART) catch |err| return @errorName(err);
    return null;
}
