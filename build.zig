const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "webviewer",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const exe_check = b.addExecutable(.{
        .name = "webviewer",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const webview = b.dependency("webview", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("webview", webview.module("webview"));
    exe.linkLibrary(webview.artifact("webviewStatic"));

    exe_check.root_module.addImport("webview", webview.module("webview"));
    exe_check.linkLibrary(webview.artifact("webviewStatic"));

    const clap = b.dependency("clap", .{});
    exe.root_module.addImport("clap", clap.module("clap"));
    exe_check.root_module.addImport("clap", clap.module("clap"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&exe_check.step);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
