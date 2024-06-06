const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zig-river-config", .{ .root_source_file = b.path("src/root.zig") });

    const lib = b.addStaticLibrary(.{
        .name = "zrc",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    const build_default_opt = b.option(bool, "init", "Build default config") orelse false;

    if (build_default_opt) {
        const default_config = b.addExecutable(.{
            .name = "init",
            .root_source_file = b.path("src/init.zig"),
            .optimize = optimize,
            .target = target,
        });
        b.installArtifact(default_config);
    }

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
