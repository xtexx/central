const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .arm,
            .os_tag = .linux,
            .abi = .musleabihf,
        },
    });
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "init",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .pic = true,
        .single_threaded = true,
    });
    const early_init_dep = b.dependency("hypearly_init", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("hypearly_init", early_init_dep.module("hypearly_init"));

    b.installArtifact(exe);
}
