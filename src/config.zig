const std = @import("std");
const Kf = @import("known-folders");
const Ini = @import("ini");
const fs = std.fs;
const Allocator = std.mem.Allocator;

pub fn Config(alloc: Allocator) type {
    return struct {
        const Self = @This();
        const allocator = alloc;

        var name: []const u8 = "Chibino";
        stickers_path: ?fs.Dir,
        sticker_name: ?fs.File,
        default_dir: ?fs.Dir,
        theme: ?[]const u8,

        pub fn parse() !void {
            const config_dir = try Kf.open(allocator, .roaming_configuration, .{});
            const config_file = try config_dir.?.openFile("chibino/config.ini", .{});

            var parser = Ini.parse(allocator, config_file.reader());
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
    };
}

const testing = std.testing;
test "test" {
    testing.expectEqualStrings("", "");
}
