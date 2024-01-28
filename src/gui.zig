const std = @import("std");
const ffi = @import("ffi.zig");
const c = ffi.c;

fn activate(app: *c.GtkApplication) callconv(.C) void {
    // setup the window
    const window = c.gtk_application_window_new(app);
    c.gtk_window_set_title(@ptrCast(window), "chibino");
    c.gtk_window_set_modal(@ptrCast(window), 1);
    c.gtk_window_set_resizable(@ptrCast(window), 0);
    c.gtk_window_set_icon_name(@ptrCast(window), "notes");
    c.gtk_window_set_default_size(@ptrCast(window), @as(c_int, 800), @as(c_int, 600));

    // setup the menubar
    const menuModel = null;
    _ = menuModel; // autofix
    const menu = c.gtk_popover_menu_bar_new_from_model(null);

    const button = c.gtk_menu_button_new();
    c.gtk_menu_button_set_icon_name(@ptrCast(button), "X");

    _ = c.gtk_popover_menu_bar_add_child(@ptrCast(menu), @ptrCast(button), "xbtn");
    c.gtk_application_set_menubar(@ptrCast(app), @ptrCast(menu));

    c.gtk_widget_show(@ptrCast(window));
}

pub fn init(app: *c.GtkApplication) void {
    const handler: c.GCallback = @ptrCast(&activate);
    _ = c.g_signal_connect_data(@ptrCast(app), "activate", handler, null, null, 0);
}
