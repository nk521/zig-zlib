const std = @import("std");
const Self = @This();

pub const Options = struct {
    import_name: ?[]const u8 = null,
};

pub const Library = struct {
    b: *std.Build,
    step: *std.Build.Step.Compile,

    pub fn link(self: Library, other: *std.Build.Step.Compile, opts: Options) void {
        other.addIncludePath(self.b.path("zlib"));
        other.linkLibrary(self.step);

        if (opts.import_name) |import_name|
            other.root_module.addAnonymousImport(
                import_name,
                .{ .root_source_file = self.b.path("src/main.zig") },
            );
    }
};

pub fn create(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) Library {
    const ret = b.addStaticLibrary(.{
        .name = "z",
        .target = target,
        .optimize = optimize,
    });
    ret.linkLibC();
    ret.addCSourceFiles(.{ .files = srcs, .flags = &.{"-std=c89"} });

    return Library{ .b = b, .step = ret };
}

const srcs = &.{
    "zlib/adler32.c",
    "zlib/compress.c",
    "zlib/crc32.c",
    "zlib/deflate.c",
    "zlib/gzclose.c",
    "zlib/gzlib.c",
    "zlib/gzread.c",
    "zlib/gzwrite.c",
    "zlib/inflate.c",
    "zlib/infback.c",
    "zlib/inftrees.c",
    "zlib/inffast.c",
    "zlib/trees.c",
    "zlib/uncompr.c",
    "zlib/zutil.c",
};
