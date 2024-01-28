const std = @import("std");
const ffi = @import("ffi.zig");
const c = ffi.c;

fn connectSignal(instance: c.gpointer, detailed_signal: [*c]const c.gchar, c_handler: c.GCallback, data: c.gpointer) void {
    _ = c.g_signal_connect_data(@ptrCast(instance), detailed_signal, c_handler, data, null, 0);
}

fn activate(app: *c.GtkApplication) callconv(.C) void {
    // setup the window
    const window = c.gtk_application_window_new(app);
    c.gtk_window_set_title(@ptrCast(window), "chibino");
    c.gtk_window_set_modal(@ptrCast(window), 1);
    c.gtk_window_set_resizable(@ptrCast(window), 0);
    c.gtk_window_set_default_size(@ptrCast(window), @as(c_int, 800), @as(c_int, 600));
    c.gtk_window_set_icon_name(@ptrCast(window), "application-exit");

    // Exit on ESC key press
    const eck = c.gtk_event_controller_key_new();
    c.gtk_widget_add_controller(window, eck);

    // Header
    const header_box = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 10);
    c.gtk_window_set_child(@ptrCast(window), header_box);
    const label = c.gtk_label_new("chibino");
    const exit_button = c.gtk_button_new();
    const exit_icon = c.gtk_image_new_from_icon_name("application-exit");
    c.gtk_button_set_child(@ptrCast(exit_button), exit_icon);
    c.gtk_image_set_pixel_size(@ptrCast(exit_icon), 20);

    // Header Margins
    inline for (.{ .top, .bottom, .start, .end }) |direction| {
        @field(c, "gtk_widget_set_margin_" ++ @tagName(direction))(header_box, 20);
    }

    // Signals
    connectSignal(eck, "key-pressed", @ptrCast(&handleEscapeKeypress), @ptrCast(window));
    connectSignal(exit_button, "clicked", @ptrCast(&handlePressExitButton), @ptrCast(window));

    c.gtk_box_append(@ptrCast(header_box), exit_button);
    c.gtk_box_append(@ptrCast(header_box), label);

    // show window
    c.gtk_widget_show(@ptrCast(window));
}

pub fn init(app: *c.GtkApplication) void {
    const handler: c.GCallback = @ptrCast(&activate);
    connectSignal(app, "activate", handler, null);
}

fn handleEscapeKeypress(
    eck: *c.GtkEventControllerKey,
    keyval: c.guint,
    keycode: c.guint,
    state: c.GdkModifierType,
    win: *c.GtkWindow,
) c.gboolean {
    _ = eck;
    _ = keycode;
    _ = state;

    if (keyval == c.GDK_KEY_Escape) {
        c.gtk_window_close(win);
        return 1;
    } else {
        return 0;
    }
}

fn handlePressExitButton(
    state: c.GdkModifierType,
    win: *c.GtkWindow,
) c.gboolean {
    _ = state; // autofix
    c.gtk_window_close(win);
    return 1;
}
