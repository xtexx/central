const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const log_dep = b.dependency("hyplog", .{
        .target = target,
        .optimize = optimize,
    });
    const init_dep = b.dependency("hypinit", .{
        .target = target,
        .optimize = optimize,
    });
    const module = b.addModule("hyploader", .{
        .root_source_file = .{ .path = "src/root.zig" },
    });
    module.addImport("hyplog", log_dep.module("hyplog"));
    module.addImport("hypinit", init_dep.module("hypinit"));

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_tests.root_module.addImport("hyplog", log_dep.module("hyplog"));
    main_tests.root_module.addImport("hypinit", init_dep.module("hypinit"));

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
