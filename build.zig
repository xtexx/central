const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .loongarch64,
        .cpu_model = .{ .explicit = &std.Target.loongarch.cpu.generic_la64 },
        .cpu_features_add = std.Target.loongarch.featureSet(&.{
            .ld_seq_sa,
            .prefer_w_inst,
            .relax,
            .div32,
        }),
        .abi = .muslsf,
        .ofmt = .elf,
        .os_tag = .freestanding,
    });
    const host_target = b.standardTargetOptions(.{});
    const host_optimize = b.standardOptimizeOption(.{});

    // gen_decode_tree
    const tools_gen_decode_tree = b.addExecutable(.{
        .name = "gen_decode_tree",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/gen_decode_tree.zig"),
            .target = host_target,
            .optimize = host_optimize,
        }),
    });
    b.installArtifact(tools_gen_decode_tree);

    // bin2hex
    const tools_bin2hex = b.addExecutable(.{
        .name = "bin2hex",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/bin2hex.zig"),
            .target = host_target,
            .optimize = host_optimize,
        }),
    });
    b.installArtifact(tools_bin2hex);

    // Firmware
    const fw_exe = b.addExecutable(.{
        .name = "tyro-firmware",
        .use_llvm = true,
        .use_lld = true,
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("firmware/main.zig"),
            .target = target,
            .optimize = .small,
            .code_model = .normal,
            .pic = false,
            .single_threaded = true,
            .imports = &.{},
            .link_libc = false,
            .link_libcpp = false,
            .strip = true,
            .error_tracing = false,
            .stack_protector = false,
        }),
    });
    fw_exe.setLinkerScript(b.path("firmware/linker.ld"));
    fw_exe.build_id = .sha1;
    fw_exe.image_base = 0;
    fw_exe.lto = .full;
    fw_exe.pie = false;
    fw_exe.entry = .{ .symbol_name = "start" };
    fw_exe.root_module.strip = false;
    b.getInstallStep().dependOn(&b.addInstallFile(fw_exe.getEmittedBin(), "tyro-firmware.elf").step);

    const fw_objcopy = fw_exe.addObjCopy(.{
        .format = .binary,
        .only_section = ".text",
        .pad_to = 64 * 1024,
    });
    b.getInstallStep().dependOn(&b.addInstallFile(fw_objcopy.getOutput(), "tyro-firmware.bin").step);

    const fw_bin2hex = b.addRunArtifact(tools_bin2hex);
    fw_bin2hex.addFileArg(fw_objcopy.getOutput());
    const fw_hex = fw_bin2hex.addOutputFileArg2("firmware.hex", .{});
    fw_bin2hex.addArg("64");

    b.getInstallStep().dependOn(&b.addInstallFile(fw_hex, "tyro-firmware.hex").step);

    // Verilator
    const verilator_path = b.findProgramLazy(.{ .names = &.{"verilator"} });
    const tools_vl_wrapper = b.addExecutable(.{
        .name = "verilator_wrapper",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/verilator_wrapper.zig"),
            .target = host_target,
            .optimize = host_optimize,
        }),
    });
    const run_vl = b.addRunArtifact(tools_vl_wrapper);
    run_vl.addFileArg2(verilator_path, .{});
    _ = run_vl.addDepFileOutputArg2("vl.d", .{});
    const vl_out = run_vl.addOutputDirectoryArg2("vl", .{});

    run_vl.addArgs(&.{ "--compiler", "clang" });
    run_vl.addArgs(&.{ "--prefix", "Vtyro" });
    run_vl.addArgs(&.{ "--make", "json" });
    run_vl.addArgs(&.{ "--cc", "--trace-fst" });
    run_vl.addArg("-f");
    run_vl.addFileArg2(b.path("tyro-core.verilator.f"), .{});
    run_vl.addFileArg2(b.path("rtl/config.vlt"), .{});

    const tb_mod = b.createModule(.{
        .root_source_file = null,
        .target = host_target,
        .optimize = .fast,
        .link_libc = true,
        .link_libcpp = true,
    });
    tb_mod.addIncludePath(.{ .cwd_relative = "/usr/share/verilator/include/" });
    tb_mod.addIncludePath(.{ .cwd_relative = "/usr/share/verilator/include/vltstd/" });
    tb_mod.addIncludePath(vl_out);
    tb_mod.addCMacro("VL_VERILATED_INCLUDE", "\"custom_verilated.h\"");
    tb_mod.addCMacro("VM_COVERAGE", "0");
    tb_mod.addCMacro("VM_SC", "0");
    tb_mod.addCMacro("VM_TRACE", "1");
    tb_mod.addCMacro("VM_TRACE_FST", "1");
    tb_mod.addCMacro("VM_TRACE_SAIF", "0");
    tb_mod.addCMacro("VM_TRACE_VCD", "0");
    tb_mod.addIncludePath(b.path("testbench"));
    const tb_flags: []const []const u8 = &.{"-std=c++23"};
    const tb_flags_fast: []const []const u8 = &.{"-O3"};
    const tb_flags_slow: []const []const u8 = &.{"-O2"};
    tb_mod.addCSourceFile(.{
        .file = vl_out.path(b, "group_global.cpp"),
        .flags = tb_flags_fast ++ tb_flags,
        .language = .cpp,
    });
    tb_mod.addCSourceFile(.{
        .file = vl_out.path(b, "group_classes_slow.cpp"),
        .flags = tb_flags_slow ++ tb_flags,
        .language = .cpp,
    });
    tb_mod.addCSourceFile(.{
        .file = vl_out.path(b, "group_classes_fast.cpp"),
        .flags = tb_flags_fast ++ tb_flags,
        .language = .cpp,
    });
    tb_mod.addCSourceFile(.{
        .file = vl_out.path(b, "group_support_slow.cpp"),
        .flags = tb_flags_slow ++ tb_flags,
        .language = .cpp,
    });
    tb_mod.addCSourceFile(.{
        .file = vl_out.path(b, "group_support_fast.cpp"),
        .flags = tb_flags_fast ++ tb_flags,
        .language = .cpp,
    });
    tb_mod.addCSourceFiles(.{
        .root = b.path("testbench"),
        .files = &.{
            "main.cpp",
            "monitor_utils.cpp",
            "core_mon.cpp",
            "frontend_mon.cpp",
            "backend_mon.cpp",
        },
        .flags = tb_flags_fast ++ tb_flags,
        .language = .cpp,
    });
    tb_mod.linkSystemLibrary("z", .{ .needed = true });
    tb_mod.linkSystemLibrary("lz4", .{ .needed = true });
    const tb_exe = b.addExecutable(.{
        .name = "tyro-tb",
        .root_module = tb_mod,
    });
    b.installArtifact(tb_exe);
}
