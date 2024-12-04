const Puzzle = @import("Puzzle.zig");
const build_options = @import("build_options");
const std = @import("std");

const Args = struct {
    day: ?usize,
    help: bool,
    version: bool,
    print_problem: bool,
};
const puzzles = [_]Puzzle{
    @import("001/001.zig").init(),
    @import("002/002.zig").init(),
    @import("003/003.zig").init(),
    @import("004/004.zig").init(),
};

fn parse_args(args: *std.process.ArgIterator) !Args {
    var day: ?usize = null;
    var print_problem = false;
    var help = false;
    var version = false;

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--version")) {
            version = true;
        } else if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            help = true;
        } else if (std.mem.eql(u8, arg, "-p") or std.mem.eql(u8, arg, "--problem")) {
            print_problem = true;
        } else {
            day = try std.fmt.parseUnsigned(usize, arg, 10);
        }
    }
    return .{
        .day = day,
        .print_problem = print_problem,
        .help = help,
        .version = version,
    };
}

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    _ = args.skip();

    const parsed_args = try parse_args(&args);
    if (parsed_args.version) {
        return try stdout.print("{s}\n", .{build_options.version});
    } else if (parsed_args.help) {
        return try stdout.print(
            \\Usage: aoc24 <day> [options]
            \\          
            \\      Options:
            \\          --problem, -p   Print day's problem to solve
            \\          --version, -v   Print version string
            \\          --help, -h      Print this message
            \\
            \\
        , .{});
    }

    const day = parsed_args.day orelse return std.log.err("expected number (valid range: {} to {})", .{ 1, puzzles.len });
    if (day > puzzles.len or day == 0) {
        return std.log.err("{}: not a valid day (valid range: {} to {})", .{ day, 1, puzzles.len });
    }
    const puzzle = puzzles[day - 1];
    if (parsed_args.print_problem) {
        return try stdout.print("{s}\n", .{puzzle.problem});
    }
    try puzzle.part_one(alloc);
    try puzzle.part_two(alloc);
}
