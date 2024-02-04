const std = @import("std");
const Kf = @import("known-folders");
const Ini = @import("ini");
const fs = std.fs;
const Allocator = std.mem.Allocator;

const Self = @This();
allocator: Allocator,
// name of the file editing
name: []const u8 = "Chibino",
// This will be optionally a png sticker
// on the corner of the app
sticker_file: ?fs.File,
default_dir: ?fs.Dir,
// name of the gtk theme
// this is still only an idea but I want to
// implement a theme selector
theme: ?[]const u8,

// init will already give the default configs
// so if parse fails the default configs can still be used
pub fn init(allocator: Allocator) Self {
    return Self{
        .allocator = allocator,
        .sticker_file = null,
        .default_dir = null,
        .theme = null,
    };
}

pub fn parse(self: *Self) !Self {
    const config_dir = try Kf.open(self.allocator, .roaming_configuration, .{});
    const config_file = try config_dir.?.openFile("chibino/config.ini", .{});

    var parser = Ini.parse(self.allocator, config_file.reader());
    defer parser.deinit();

    while (try parser.next()) |line| {
        switch (line) {
            .section => |sec| {
                std.debug.print("section {s}\n", .{sec});
            },
            .property => |prop| {
                std.debug.print("property, key: {s} value {s}\n", .{ prop.key, prop.value });
            },
            .enumeration => |enumer| {
                std.debug.print("enumeration {s}\n", .{enumer});
            },
        }
    }
}

const testing = std.testing;
test "test" {
    testing.expectEqualStrings("", "");
}
