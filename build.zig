const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const hlslcc = b.addLibrary(.{
        .name = "hlslcc",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    hlslcc.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{
            "ControlFlowGraph.cpp",
            "ControlFlowGraphUtils.cpp",
            "DataTypeAnalysis.cpp",
            "Declaration.cpp",
            "decode.cpp",
            "HLSLcc.cpp",
            "HLSLccToolkit.cpp",
            "HLSLCrossCompilerContext.cpp",
            "Instruction.cpp",
            "LoopTransform.cpp",
            "Operand.cpp",
            "reflect.cpp",
            "Shader.cpp",
            "ShaderInfo.cpp",
            "toGLSL.cpp",
            "toGLSLDeclaration.cpp",
            "toGLSLInstruction.cpp",
            "toGLSLOperand.cpp",
            "toMetal.cpp",
            "toMetalDeclaration.cpp",
            "toMetalInstruction.cpp",
            "toMetalOperand.cpp",
            "UseDefineChains.cpp",
        },
        .flags = &.{"-std=c++11"},
    });
    hlslcc.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{
            "cbstring/bsafe.c",
            "cbstring/bstraux.c",
            "cbstring/bstrlib.c",
        },
    });
    hlslcc.linkLibCpp();
    hlslcc.addIncludePath(b.path("."));
    hlslcc.addIncludePath(b.path("include"));
    hlslcc.addIncludePath(b.path("src"));
    hlslcc.addIncludePath(b.path("src/cbstring/"));

    const exe = b.addExecutable(.{
        .name = "translate",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });
    b.installArtifact(exe);
    exe.linkLibrary(hlslcc);

    const run = b.step("run", "");
    const run_artifact = b.addRunArtifact(exe);
    if (b.args) |args| run_artifact.addArgs(args);
    run.dependOn(&run_artifact.step);
}
