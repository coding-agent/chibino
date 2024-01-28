const std = @import("std");
const ffi = @import("ffi.zig");
const c = ffi.c;

fn activate(app: *c.GtkApplication) callconv(.C) void {
    const window = c.gtk_application_window_new(app);
    c.gtk_window_set_title(@ptrCast(window), "chibino");
    c.gtk_window_set_modal(@ptrCast(window), 1);
    c.gtk_window_set_resizable(@ptrCast(window), 0);
    c.gtk_window_set_icon_name(@ptrCast(window), "notes");

    c.gtk_widget_show(@ptrCast(window));
}

pub fn init(app: *c.GtkApplication) void {
    const handler: c.GCallback = @ptrCast(&activate);
    _ = c.g_signal_connect_data(@ptrCast(app), "activate", handler, null, null, 0);
}
