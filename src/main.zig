const std = @import("std");
const ffi = @import("ffi.zig");
const gui = @import("gui.zig");
const c = ffi.c;

pub fn main() !u8 {
    const app = c.gtk_application_new(null, c.G_APPLICATION_FLAGS_NONE);
    defer c.g_object_unref(app);

    const alloc = std.heap.page_allocator;
    const config = @import("config.zig");
    const conf = config.init(alloc);
    _ = conf; // autofix

    gui.init(app);

    const status = c.g_application_run(@ptrCast(app), 0, null);
    return @intCast(status);
}

test "simple test" {}
