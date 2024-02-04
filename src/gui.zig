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
    c.gtk_window_set_resizable(@ptrCast(window), 0);
    c.gtk_window_set_default_size(@ptrCast(window), 800, 600);
    const main_box = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 2);
    c.gtk_window_set_child(@ptrCast(window), main_box);

    // Exit on ESC key press
    const eck = c.gtk_event_controller_key_new();
    c.gtk_widget_add_controller(window, eck);

    // Header
    const header_box = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 20);
    const header_label = c.gtk_label_new("  " ++ "Chibino");
    const exit_button = c.gtk_button_new();
    const exit_icon = c.gtk_image_new_from_icon_name("application-exit");
    c.gtk_button_set_child(@ptrCast(exit_button), exit_icon);
    c.gtk_image_set_pixel_size(@ptrCast(exit_icon), 20);
    c.gtk_box_append(@ptrCast(header_box), exit_button);
    c.gtk_box_append(@ptrCast(header_box), header_label);

    // Text view
    const body_box = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 2);
    const text_view = c.gtk_text_view_new();
    c.gtk_text_view_set_wrap_mode(@ptrCast(text_view), c.GTK_WRAP_WORD);
    c.gtk_text_view_set_editable(@ptrCast(text_view), 1);
    c.gtk_widget_set_size_request(@ptrCast(text_view), -1, (600 - 20 * 4 - c.gtk_widget_get_height(@ptrCast(header_box))));
    c.gtk_box_append(@ptrCast(body_box), @ptrCast(text_view));
    c.gtk_widget_set_visible(@ptrCast(text_view), 0);

    // Initial menu
    const new_file_label = c.gtk_label_new("New Note");
    const new_file_button = c.gtk_button_new();
    c.gtk_button_set_child(@ptrCast(new_file_button), @ptrCast(new_file_label));
    const open_file_label = c.gtk_label_new("Open Note");
    const open_file_button = c.gtk_button_new();
    c.gtk_button_set_child(@ptrCast(open_file_button), @ptrCast(open_file_label));
    const initial_menu = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 5);
    c.gtk_box_append(@ptrCast(initial_menu), @ptrCast(new_file_button));
    c.gtk_box_append(@ptrCast(initial_menu), @ptrCast(open_file_button));
    c.gtk_box_append(@ptrCast(body_box), @ptrCast(initial_menu));

    // Margins
    inline for (.{ .top, .bottom, .start, .end }) |direction| {
        @field(c, "gtk_widget_set_margin_" ++ @tagName(direction))(header_box, 20);
        @field(c, "gtk_widget_set_margin_" ++ @tagName(direction))(body_box, 20);
    }

    // Appending boxes
    c.gtk_box_append(@ptrCast(main_box), @ptrCast(header_box));
    c.gtk_box_append(@ptrCast(main_box), @ptrCast(body_box));

    // Signals
    connectSignal(new_file_button, "clicked", @ptrCast(&handleNewFileButton), @ptrCast(window));
    connectSignal(open_file_button, "clicked", @ptrCast(&handleOpenFileButton), @ptrCast(window));
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
    _ = state;
    c.gtk_window_close(win);
    return 1;
}

fn handleNewFileButton(
    state: c.GdkModifierType,
    win: *c.GtkWindow,
) void {
    _ = state; // autofix
    _ = win; // autofix
}
fn handleOpenFileButton(
    state: c.GdkModifierType,
    win: *c.GtkWindow,
    label: *c.GtkLabel,
    menu_box: *c.GtkBox,
    body_box: *c.GtkBox,
) void {
    _ = menu_box; // autofix
    _ = body_box; // autofix
    _ = state; // autofix
    _ = label; // autofix

    //const action = c.GTK_FILE_CHOOSER_ACTION_OPEN;
    //const dialog = c.gtk_file_chooser_dialog_new("Choose your notes", win, action, "open", c.GTK_RESPONSE_ACCEPT);
    //c.gtk_window_present(@ptrCast(dialog));
    //connectSignal(@ptrCast(dialog), "response", @ptrCast(&openResponse), null);

    const dialog = c.gtk_file_dialog_new();
    c.gtk_file_dialog_open(dialog, win, c.g_cancellable_new(), @ptrCast(&openResponse), null);
}

fn openResponse(dialog: anytype, response: c_int) void {
    _ = dialog; // autofix
    if (response == c.GTK_RESPONSE_ACCEPT) {
        std.debug.print("accept {}\n", .{response});
        //const chooser = c.gtk_file_chooser_get_file(@ptrCast(dialog));
        //const file = c.gtk_file_chooser_get_file(chooser);
        //const input_stream = c.g_file_read(file, null, null);
        //const info = c.g_file_input_stream_query_info(input_stream, null, null, null);
        //const file_path = c.g_file_info_get_attribute_file_path(@ptrCast(info), null);
        //std.debug.print("path: {}\n", .{file_path});
    }
    //c.gtk_window_destroy(@ptrCast(dialog));
}
