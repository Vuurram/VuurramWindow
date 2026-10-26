const std = @import("std");
const glfw = @import("zglfw");
const zigimg = @import("zigimg");

pub const Config = struct {
    title: [:0]const u8 = "VuurramWindow",
    width: c_int = 1280,
    height: c_int = 720,
};

pub const Window = struct {
    handle: *glfw.Window,
    allocator: std.mem.Allocator,
    io: std.Io,

    pub fn init(process: std.process.Init, config: Config) !Window {
        try glfw.init();
        errdefer glfw.terminate();

        const handle = try glfw.createWindow(
            config.width,
            config.height,
            config.title,
            null,
            null,
        );
        errdefer glfw.destroyWindow(handle);

        return .{
            .handle = handle,
            .allocator = process.gpa,
            .io = process.io,
        };
    }

    pub fn deinit(self: *Window) void {
        glfw.destroyWindow(self.handle);
        glfw.terminate();
    }

    pub fn isOpen(self: *const Window) bool {
        return !self.handle.shouldClose();
    }

    pub fn pollEvents(self: *Window) void {
        _ = self;
        glfw.pollEvents();
    }

    pub fn setTitle(self: *Window, title: [:0]const u8) void {
        self.handle.setTitle(title);
    }

    pub fn setIcon(self: *Window, path: []const u8) !void {
        var read_buffer: [4096]u8 = undefined;

        var image = try zigimg.Image.fromFilePath(
            self.allocator,
            self.io,
            path,
            &read_buffer,
        );
        defer image.deinit(self.allocator);

        try image.convert(self.allocator, .rgba32);

        const pixels = switch (image.pixels) {
            .rgba32 => |data| std.mem.sliceAsBytes(data),
            else => unreachable,
        };

        const glfw_image = glfw.Image{
            .width = @intCast(image.width),
            .height = @intCast(image.height),
            .pixels = pixels.ptr,
        };

        self.handle.setIcon(&.{glfw_image});
    }
};
