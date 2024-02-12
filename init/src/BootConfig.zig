const std = @import("std");
const log = std.log;

const Self = @This();

mutex: std.Thread.Mutex,
map: std.StringHashMap([]const u8) = undefined,
allocator: std.mem.Allocator,

pub fn init(alloc: std.mem.Allocator) Self {
    return .{
        .mutex = .{},
        .map = std.StringHashMap([]const u8).init(alloc),
        .allocator = alloc,
    };
}

pub fn load(self: *Self) !void {
    try self.loadFromBootConfig();
    try self.loadFromBootConfigFile("/usr/share/hypearly-init.config");
    try self.loadFromBootConfigFile("/etc/hypearly-init.config");
    try self.loadFromArgs();
}

fn loadFromBootConfig(self: *Self) !void {
    try self.loadFromBootConfigFile("/proc/bootconfig");
}

fn loadFromBootConfigFile(self: *Self, path: []const u8) !void {
    var file = std.fs.openFileAbsolute(path, .{ .mode = .read_only }) catch |err| switch (err) {
        error.FileNotFound => return,
        else => return err,
    };
    defer file.close();
    var reader = file.reader();
    while (true) {
        const line = try reader.readUntilDelimiterOrEofAlloc(self.allocator, '\n', 1024) orelse break;
        try self.parseProperty(line);
        self.allocator.free(line);
    }
}

fn loadFromArgs(self: *Self) !void {
    var iter = std.process.args();
    try std.testing.expect(iter.skip());
    while (iter.next()) |arg| {
        try self.parseProperty(arg);
    }
}

pub fn parseProperty(self: *Self, str: []const u8) !void {
    const Phase = enum { begin_key, key_quoted, key_raw, equals, begin_value, value_quoted, value_raw, end, comment };
    var phase = Phase.begin_key;
    var separator: u8 = undefined;
    var prop = str;

    var key = std.ArrayList(u8).init(self.allocator);
    defer key.deinit();
    var value = std.ArrayList(u8).init(self.allocator);
    defer value.deinit();

    while (prop.len > 0) {
        const char = prop[0];
        switch (phase) {
            .begin_key => switch (char) {
                '\'' => {
                    separator = '\'';
                    phase = .key_quoted;
                },
                '"' => {
                    separator = '"';
                    phase = .key_quoted;
                },
                ' ' => {},
                '#', '\n' => return,
                'a'...'z', 'A'...'Z', '0'...'9', '-', '_' => {
                    phase = .key_raw;
                    continue;
                },
                else => return error.InvalidKey,
            },
            .key_quoted => switch (char) {
                'a'...'z', 'A'...'Z', '0'...'9', '-', '_', '.' => try key.append(char),
                else => {
                    if (char == separator)
                        phase = .equals
                    else
                        return error.InvalidKey;
                },
            },
            .key_raw => switch (char) {
                ' ', '=' => {
                    phase = .equals;
                    continue;
                },
                'a'...'z', 'A'...'Z', '0'...'9', '-', '_', '.' => {
                    try key.append(char);
                },
                else => return error.InvalidKey,
            },
            .equals => switch (char) {
                ' ' => {},
                '=' => phase = .begin_value,
                else => return error.ExpectedEquals,
            },
            .begin_value => switch (char) {
                '\'' => {
                    separator = '\'';
                    phase = .value_quoted;
                },
                '"' => {
                    separator = '"';
                    phase = .value_quoted;
                },
                ' ' => {},
                '#', '\n', ';' => return error.InvalidValue,
                else => {
                    if (33 <= char and char <= 126) {
                        phase = .value_raw;
                        continue;
                    } else return error.InvalidValue;
                },
            },
            .value_quoted => {
                if (char == separator)
                    phase = .end
                else
                    try switch (char) {
                        33...126 => value.append(char),
                        else => error.InvalidValue,
                    };
            },
            .value_raw => switch (char) {
                ';', '\n' => {
                    phase = .end;
                    continue;
                },
                '#' => phase = .comment,
                else => switch (char) {
                    33...126 => try value.append(char),
                    else => return error.InvalidValue,
                },
            },
            .end => switch (char) {
                '\n', ' ' => continue,
                ',' => {
                    phase = .begin_value;
                    try value.append(0);
                },
                '#' => phase = .comment,
                else => return error.UnexpectedCharAfterEnd,
            },
            .comment => {},
        }
        prop = prop[1..];
    }
    switch (phase) {
        .value_raw, .end, .comment => {
            self.mutex.lock();
            defer self.mutex.unlock();
            try self.map.put(key.items, value.items);
        },
        else => return error.UnexpectedEnd,
    }
}

pub fn get(self: *Self, key: []const u8) ?[]const u8 {
    self.mutex.lock();
    defer self.mutex.unlock();
    const value = self.map.get(key) orelse return null;
    return value;
}
