const std = @import("std");
const ffi = @import("ffi.zig");
const c = ffi.c;

fn connectSignal(instance: c.gpointer, detailed_signal: [*c]const c.gchar, c_handler: c.GCallback, data: c.gpointer) void {
    _ = c.g_signal_connect_data(@ptrCast(instance), detailed_signal, c_handler, data, null, 0);
}

fn activate(app: *c.GtkApplication) callconv(.C) void {
    // setup the window
    const window = c.gtk_application_window_new(app);
    c.gtk_window_set_title(@ptrCast(window), "Chibino");
    c.gtk_window_set_modal(@ptrCast(window), 1);
    c.gtk_window_set_resizable(@ptrCast(window), 1);
    c.gtk_window_set_default_size(@ptrCast(window), @as(c_int, 800), @as(c_int, 600));
    const main_box = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 2);
    c.gtk_window_set_child(@ptrCast(window), main_box);

    // Exit on ESC key press
    const eck = c.gtk_event_controller_key_new();
    c.gtk_widget_add_controller(window, eck);

    // Header
    const header_box = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 20);
    const label = c.gtk_label_new("   Chibino");
    const exit_button = c.gtk_button_new();
    const exit_icon = c.gtk_image_new_from_icon_name("application-exit");
    c.gtk_button_set_child(@ptrCast(exit_button), exit_icon);
    c.gtk_image_set_pixel_size(@ptrCast(exit_icon), 20);
    c.gtk_box_append(@ptrCast(header_box), exit_button);
    c.gtk_box_append(@ptrCast(header_box), label);

    // Text view
    const body_box = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 2);
    const text_view = c.gtk_text_view_new();
    c.gtk_text_view_set_wrap_mode(@ptrCast(text_view), c.GTK_WRAP_WORD);
    c.gtk_text_view_set_editable(@ptrCast(text_view), 1);
    c.gtk_widget_set_size_request(@ptrCast(text_view), -1, 200);
    c.gtk_box_append(@ptrCast(body_box), @ptrCast(text_view));

    // Margins
    inline for (.{ .top, .bottom, .start, .end }) |direction| {
        @field(c, "gtk_widget_set_margin_" ++ @tagName(direction))(header_box, 20);
        @field(c, "gtk_widget_set_margin_" ++ @tagName(direction))(body_box, 20);
    }

    // Appending boxes
    c.gtk_box_append(@ptrCast(main_box), @ptrCast(header_box));
    c.gtk_box_append(@ptrCast(main_box), @ptrCast(body_box));

    // Signals
    connectSignal(eck, "key-pressed", @ptrCast(&handleEscapeKeypress), @ptrCast(window));
    connectSignal(exit_button, "clicked", @ptrCast(&handlePressExitButton), @ptrCast(window));

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
