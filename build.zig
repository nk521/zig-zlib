const std = @import("std");
const zlib = @import("zlib.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Modules available to downstream dependencies
    _ = b.addModule("zlib", .{
        .root_source_file = b.path("src/main.zig"),
    });

    const lib = zlib.create(b, target, optimize);
    b.installArtifact(lib.step);

    const tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
    });
    lib.link(tests, .{});

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&tests.step);

    const bin = b.addExecutable(.{
        .name = "example1",
        .root_source_file = b.path("example/example1.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.link(bin, .{ .import_name = "zlib" });
    b.installArtifact(bin);
}
