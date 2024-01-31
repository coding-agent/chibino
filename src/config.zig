const std = @import("std");
const kf = @import("known-folders");
const fs = std.fs;
const Ini = std.Ini;
const Allocator = std.mem.Allocator;

pub fn Config(alloc: Allocator) type {
    return struct {
        const Self = @This();
        const allocator = alloc;

        pub fn parser() !void {
            const config_dir = try kf.open(allocator, .roaming_configuration, .{});
            const config_file = try config_dir.?.openFile("chibino/config.ini", .{});

            const file_buffer = try config_file.readToEndAlloc(allocator, 4000);
            defer allocator.free(file_buffer);

            const ini: Ini = .{ .bytes = file_buffer };
            var it_example = ini.iterateSection("\n[config]\n");

            while (it_example.next()) |it| {
                std.debug.print("{s}", .{it});
            }
        }
    };
}

const testing = std.testing;
test "test" {
    testing.expectEqualStrings("", "");
}
