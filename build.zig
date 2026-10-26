const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zglfw = b.dependency("zglfw", .{
        .target = target,
        .optimize = optimize,
    });

    const zigimg = b.dependency("zigimg", .{
        .target = target,
        .optimize = optimize,
    });

    const window_module = b.addModule("mywindow", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "zglfw",
                .module = zglfw.module("root"),
            },
            .{
                .name = "zigimg",
                .module = zigimg.module("zigimg"),
            },
        },
    });

    window_module.linkLibrary(zglfw.artifact("glfw"));

    const example = b.addExecutable(.{
        .name = "basic_window",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/basic_window.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{
                    .name = "vuurramwindow",
                    .module = window_module,
                },
            },
        }),
    });

    b.installArtifact(example);
}
