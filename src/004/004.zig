const Puzzle = @import("../Puzzle.zig");
const Self = @This();
const input = @embedFile("input.txt");
const print = std.debug.print;
const std = @import("std");

const problem =
    \\ --- Day 4: Ceres Search ---
    \\ 
    \\ "Looks like the Chief's not here. Next!" One of The Historians pulls out a device and pushes the only button on it. After a brief flash, you recognize the interior of the Ceres monitoring station!
    \\ 
    \\ As the search for the Chief continues, a small Elf who lives on the station tugs on your shirt; she'd like to know if you could help her with her word search (your puzzle input). She only has to find one word: XMAS.
    \\ 
    \\ This word search allows words to be horizontal, vertical, diagonal, written backwards, or even overlapping other words. It's a little unusual, though, as you don't merely need to find one instance of XMAS - you need to find all of them. Here are a few ways XMAS might appear, where irrelevant characters have been replaced with .:
    \\ 
    \\ ..X...
    \\ .SAMX.
    \\ .A..A.
    \\ XMAS.S
    \\ .X....
    \\ 
    \\ The actual word search will be full of letters instead. For example:
    \\ 
    \\ MMMSXXMASM
    \\ MSAMXMSMSA
    \\ AMXSXMAAMM
    \\ MSAMASMSMX
    \\ XMASAMXAMM
    \\ XXAMMXXAMA
    \\ SMSMSASXSS
    \\ SAXAMASAAA
    \\ MAMMMXMMMM
    \\ MXMXAXMASX
    \\ 
    \\ In this word search, XMAS occurs a total of 18 times; here's the same word search again, but where letters not involved in any XMAS have been replaced with .:
    \\ 
    \\ ....XXMAS.
    \\ .SAMXMS...
    \\ ...S..A...
    \\ ..A.A.MS.X
    \\ XMASAMX.MM
    \\ X.....XA.A
    \\ S.S.S.S.SS
    \\ .A.A.A.A.A
    \\ ..M.M.M.MM
    \\ .X.X.XMASX
    \\ 
    \\ Take a look at the little Elf's word search. How many times does XMAS appear?
    \\ 
    \\ --- Part Two ---
    \\ 
    \\ The Elf looks quizzically at you. Did you misunderstand the assignment?
    \\ 
    \\ Looking for the instructions, you flip over the word search to find that this isn't actually an XMAS puzzle; it's an X-MAS puzzle in which you're supposed to find two MAS in the shape of an X. One way to achieve that is like this:
    \\ 
    \\ M.S
    \\ .A.
    \\ M.S
    \\ 
    \\ Irrelevant characters have again been replaced with . in the above diagram. Within the X, each MAS can be written forwards or backwards.
    \\ 
    \\ Here's the same example from before, but this time all of the X-MASes have been kept instead:
    \\ 
    \\ .M.S......
    \\ ..A..MSMS.
    \\ .M.S.MAA..
    \\ ..A.ASMSM.
    \\ .M.S.M....
    \\ ..........
    \\ S.S.S.S.S.
    \\ .A.A.A.A..
    \\ M.M.M.M.M.
    \\ ..........
    \\ 
    \\ In this example, an X-MAS appears 9 times.
    \\ 
    \\ Flip the word search from the instructions back over to the word search side and try again. How many times does an X-MAS appear?
;

fn part_one(alloc: std.mem.Allocator) !void {
    const solution: usize = 2593;
    const stdout = std.io.getStdOut().writer();
    var xmas: usize = 0;

    var iter = std.mem.splitScalar(u8, input, '\n');
    var lines_arr = std.ArrayList([]const u8).init(alloc);
    defer lines_arr.deinit();
    while (iter.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        try lines_arr.append(line);
    }
    const lines = lines_arr.items;
    const line_len = lines[0].len;

    for (0..lines.len) |i| {
        for (0..line_len) |j| {
            if (lines[i][j] == 'X') {
                // up
                {
                    const m = @as(isize, @intCast(i)) - 3;
                    const n = @as(isize, @intCast(j)) + 0;
                    if (m >= 0 and m < lines.len and n >= 0 and n < line_len) {
                        if (lines[i - 1][j + 0] == 'M' and
                            lines[i - 2][j + 0] == 'A' and
                            lines[i - 3][j + 0] == 'S')
                        {
                            xmas += 1;
                        }
                    }
                }
                // down
                {
                    const m = @as(isize, @intCast(i)) + 3;
                    const n = @as(isize, @intCast(j)) + 0;
                    if (m >= 0 and m < lines.len and n >= 0 and n < line_len) {
                        if (lines[i + 1][j + 0] == 'M' and
                            lines[i + 2][j + 0] == 'A' and
                            lines[i + 3][j + 0] == 'S')
                        {
                            xmas += 1;
                        }
                    }
                }
                // up right
                {
                    const m = @as(isize, @intCast(i)) - 3;
                    const n = @as(isize, @intCast(j)) + 3;
                    if (m >= 0 and m < lines.len and n >= 0 and n < line_len) {
                        if (lines[i - 1][j + 1] == 'M' and
                            lines[i - 2][j + 2] == 'A' and
                            lines[i - 3][j + 3] == 'S')
                        {
                            xmas += 1;
                        }
                    }
                }
                // down right
                {
                    const m = @as(isize, @intCast(i)) + 3;
                    const n = @as(isize, @intCast(j)) + 3;
                    if (m >= 0 and m < lines.len and n >= 0 and n < line_len) {
                        if (lines[i + 1][j + 1] == 'M' and
                            lines[i + 2][j + 2] == 'A' and
                            lines[i + 3][j + 3] == 'S')
                        {
                            xmas += 1;
                        }
                    }
                }
                // up left
                {
                    const m = @as(isize, @intCast(i)) - 3;
                    const n = @as(isize, @intCast(j)) - 3;
                    if (m >= 0 and m < lines.len and n >= 0 and n < line_len) {
                        if (lines[i - 1][j - 1] == 'M' and
                            lines[i - 2][j - 2] == 'A' and
                            lines[i - 3][j - 3] == 'S')
                        {
                            xmas += 1;
                        }
                    }
                }
                // down left
                {
                    const m = @as(isize, @intCast(i)) + 3;
                    const n = @as(isize, @intCast(j)) - 3;
                    if (m >= 0 and m < lines.len and n >= 0 and n < line_len) {
                        if (lines[i + 1][j - 1] == 'M' and
                            lines[i + 2][j - 2] == 'A' and
                            lines[i + 3][j - 3] == 'S')
                        {
                            xmas += 1;
                        }
                    }
                }
            }
        }
    }

    const forward = std.mem.count(u8, input, "XMAS");
    const backward = std.mem.count(u8, input, "SAMX");
    xmas += forward + backward;

    try stdout.print("xmas: {}\n", .{xmas});
    std.debug.assert(xmas == solution);
}

fn part_two(alloc: std.mem.Allocator) !void {
    const solution: usize = 1950;
    const stdout = std.io.getStdOut().writer();
    var mas: usize = 0;

    var iter = std.mem.splitScalar(u8, input, '\n');
    var lines_arr = std.ArrayList([]const u8).init(alloc);
    defer lines_arr.deinit();
    while (iter.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        try lines_arr.append(line);
    }
    const lines = lines_arr.items;
    const line_len = lines[0].len;

    for (0..lines.len) |i| {
        for (0..line_len) |j| {
            if (lines[i][j] == 'A') {
                const m = @as(isize, @intCast(i)) + 1;
                const n = @as(isize, @intCast(j)) - 1;
                const o = @as(isize, @intCast(i)) - 1;
                const p = @as(isize, @intCast(j)) + 1;
                if (m >= 0 and m < lines.len and n >= 0 and n < line_len and
                    o >= 0 and o < lines.len and p >= 0 and p < line_len)
                {
                    if ((lines[i - 1][j - 1] == 'M' and
                        lines[i + 1][j + 1] == 'S' or
                        lines[i - 1][j - 1] == 'S' and
                        lines[i + 1][j + 1] == 'M') and
                        (lines[i - 1][j + 1] == 'M' and
                        lines[i + 1][j - 1] == 'S' or
                        lines[i - 1][j + 1] == 'S' and
                        lines[i + 1][j - 1] == 'M'))
                    {
                        mas += 1;
                    }
                }
            }
        }
    }

    try stdout.print("mas: {}\n", .{mas});
    std.debug.assert(mas == solution);
}

pub fn init() Puzzle {
    return .{
        .problem = problem,
        .part_one = part_one,
        .part_two = part_two,
    };
}
