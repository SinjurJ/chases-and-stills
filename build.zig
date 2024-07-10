const std = @import("std");

const LinuxDisplayBackend = enum { X11, Wayland };

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const x11 = b.option(bool, "x11", "On Linux, use X11 instead of Wayland") orelse false;

    const exe = b.addExecutable(.{
        .name = "chases-and-stills",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const raylib_dep = b.dependency("raylib-zig", .{
        .target = target,
        .optimize = optimize,
        .linux_display_backend = blk: {
            if (b.graph.host.result.os.tag == .linux and std.mem.eql(u8, std.posix.getenvZ("XDG_SESSION_TYPE") orelse "", "wayland")) {
                break :blk if (x11) LinuxDisplayBackend.X11 else LinuxDisplayBackend.Wayland;
            }
            break :blk LinuxDisplayBackend.X11;
        },
    });

    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
