const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .arm,
            .os_tag = .linux,
            .abi = .musleabihf,
            .cpu_model = .{ .explicit = &std.Target.arm.cpu.krait },
        },
    });
    const optimize = b.standardOptimizeOption(.{});

    const loader_dep = b.dependency("hyploader", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "loader",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .single_threaded = true,
        .strip = true,
    });
    exe.root_module.addImport("hyploader", loader_dep.module("hyploader"));

    b.installArtifact(exe);
}
