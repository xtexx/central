const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .loongarch64,
        .cpu_model = .{ .explicit = &std.Target.loongarch.cpu.generic_la64 },
        .cpu_features_add = std.Target.loongarch.featureSet(&.{
            .ld_seq_sa,
            .prefer_w_inst,
            .relax,
        }),
        .abi = .muslsf,
        .ofmt = .elf,
        .os_tag = .freestanding,
    });
    const host_target = b.resolveTargetQuery(.{});

    const obj = b.addObject(.{
        .name = "tyro-core-firmware",
        .use_llvm = true,
        .use_lld = true,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = .small,
            .code_model = .normal,
            .pic = false,
            .single_threaded = true,
            .imports = &.{},
            .link_libc = false,
            .link_libcpp = false,
            .strip = true,
        }),
    });
    obj.setLinkerScript(b.path("src/linker.ld"));
    b.getInstallStep().dependOn(&b.addInstallFile(obj.getEmittedBin(), "tyro-core-firmware.o").step);

    const objcopy = obj.addObjCopy(.{
        .format = .binary,
        .only_section = ".text",
        .pad_to = 64 * 1024,
    });
    b.getInstallStep().dependOn(&b.addInstallFile(objcopy.getOutput(), "tyro-core-firmware.bin").step);

    const bin2hex = b.addExecutable(.{
        .name = "bin2hex",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/bin2hex.zig"),
            .target = host_target,
        }),
    });
    const run_bin2hex = b.addRunArtifact(bin2hex);
    run_bin2hex.addFileArg(objcopy.getOutput());
    const hex_out = run_bin2hex.addOutputFileArg2("firmware.hex", .{});

    b.getInstallStep().dependOn(&b.addInstallFile(hex_out, "tyro-core-firmware.hex").step);
}
