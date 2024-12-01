const std = @import("std");

fn getVersion(alloc: std.mem.Allocator) !struct { date: []const u8, commit: []const u8 } {
    const result = try std.process.Child.run(.{
        .allocator = alloc,
        .argv = &.{ "date", "+%Y%m%d" },
    });
    const date = std.mem.trim(u8, result.stdout, &std.ascii.whitespace);

    const git_result = try std.process.Child.run(.{
        .allocator = alloc,
        .argv = &.{ "git", "rev-parse", "--short", "HEAD" },
    });
    const commit = std.mem.trim(u8, git_result.stdout, &std.ascii.whitespace);

    return .{
        .date = date,
        .commit = commit,
    };
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const debug = optimize == .Debug;
    const version = getVersion(b.allocator) catch |err| {
        return std.log.err("Failed to get version info: {}", .{err});
    };

    const exe = b.addExecutable(.{
        .name = "aoc24",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .strip = !debug,
        .single_threaded = !debug,
    });
    const options = b.addOptions();
    options.addOption([]const u8, "version", b.fmt("{s}-{s}", .{ version.date, version.commit }));
    exe.root_module.addOptions("build_options", options);
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run program");
    run_step.dependOn(&run_cmd.step);
}
