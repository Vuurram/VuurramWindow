const std = @import("std");
const mywindow = @import("vuurramwindow");

pub fn main(process: std.process.Init) !void {
    var window = try mywindow.Window.init(process, .{
        .title = "VuurramWindow",
        .width = 1280,
        .height = 720,
    });
    defer window.deinit();

    try window.setIcon("assets/icon.png");

    while (window.isOpen()) {
        window.pollEvents();
    }
}
