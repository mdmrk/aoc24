const Puzzle = @import("../Puzzle.zig");
const Self = @This();
const std = @import("std");
const input = @embedFile("input.txt");
const print = std.debug.print;

const problem =
    \\ --- Day 2: Red-Nosed Reports ---
    \\ 
    \\ Fortunately, the first location The Historians want to search isn't a long walk from the Chief Historian's office.
    \\ 
    \\ While the Red-Nosed Reindeer nuclear fusion/fission plant appears to contain no sign of the Chief Historian, the engineers there run up to you as soon as they see you. Apparently, they still talk about the time Rudolph was saved through molecular synthesis from a single electron.
    \\ 
    \\ They're quick to add that - since you're already here - they'd really appreciate your help analyzing some unusual data from the Red-Nosed reactor. You turn to check if The Historians are waiting for you, but they seem to have already divided into groups that are currently searching every corner of the facility. You offer to help with the unusual data.
    \\ 
    \\ The unusual data (your puzzle input) consists of many reports, one report per line. Each report is a list of numbers called levels that are separated by spaces. For example:
    \\ 
    \\ 7 6 4 2 1
    \\ 1 2 7 8 9
    \\ 9 7 6 2 1
    \\ 1 3 2 4 5
    \\ 8 6 4 4 1
    \\ 1 3 6 7 9
    \\ 
    \\ This example data contains six reports each containing five levels.
    \\ 
    \\ The engineers are trying to figure out which reports are safe. The Red-Nosed reactor safety systems can only tolerate levels that are either gradually increasing or gradually decreasing. So, a report only counts as safe if both of the following are true:
    \\ 
    \\     The levels are either all increasing or all decreasing.
    \\     Any two adjacent levels differ by at least one and at most three.
    \\ 
    \\ In the example above, the reports can be found safe or unsafe by checking those rules:
    \\ 
    \\     7 6 4 2 1: Safe because the levels are all decreasing by 1 or 2.
    \\     1 2 7 8 9: Unsafe because 2 7 is an increase of 5.
    \\     9 7 6 2 1: Unsafe because 6 2 is a decrease of 4.
    \\     1 3 2 4 5: Unsafe because 1 3 is increasing but 3 2 is decreasing.
    \\     8 6 4 4 1: Unsafe because 4 4 is neither an increase or a decrease.
    \\     1 3 6 7 9: Safe because the levels are all increasing by 1, 2, or 3.
    \\ 
    \\ So, in this example, 2 reports are safe.
    \\ 
    \\ Analyze the unusual data from the engineers. How many reports are safe?
    \\ 
    \\ --- Part Two ---
    \\ 
    \\ The engineers are surprised by the low number of safe reports until they realize they forgot to tell you about the Problem Dampener.
    \\ 
    \\ The Problem Dampener is a reactor-mounted module that lets the reactor safety systems tolerate a single bad level in what would otherwise be a safe report. It's like the bad level never happened!
    \\ 
    \\ Now, the same rules apply as before, except if removing a single level from an unsafe report would make it safe, the report instead counts as safe.
    \\ 
    \\ More of the above example's reports are now safe:
    \\ 
    \\     7 6 4 2 1: Safe without removing any level.
    \\     1 2 7 8 9: Unsafe regardless of which level is removed.
    \\     9 7 6 2 1: Unsafe regardless of which level is removed.
    \\     1 3 2 4 5: Safe by removing the second level, 3.
    \\     8 6 4 4 1: Safe by removing the third level, 4.
    \\     1 3 6 7 9: Safe without removing any level.
    \\ 
    \\ Thanks to the Problem Dampener, 4 reports are actually safe!
    \\ 
    \\ Update your analysis by handling situations where the Problem Dampener can remove a single level from unsafe reports. How many reports are now safe?
;

fn part_one(_: std.mem.Allocator) !void {
    const solution: usize = 564;
    var r_iter = std.mem.tokenizeScalar(u8, input, '\n');
    const stdout = std.io.getStdOut().writer();
    var valid_reports: usize = 0;

    while (r_iter.next()) |report| {
        var valid_report = true;
        var l_iter = std.mem.tokenizeScalar(u8, report, ' ');
        const first: isize = try std.fmt.parseInt(isize, l_iter.next() orelse return error.Invalid, 10);
        const second: isize = try std.fmt.parseInt(isize, l_iter.next() orelse return error.Invalid, 10);
        l_iter.reset();
        _ = l_iter.next();
        var last_visited: isize = first;
        const is_asc = first < second;
        while (l_iter.next()) |level| {
            const num: isize = try std.fmt.parseInt(isize, level, 10);
            const diff = @abs(last_visited - num);
            if (diff < 1 or diff > 3) {
                valid_report = false;
                break;
            }
            if (is_asc) {
                if (last_visited > num) {
                    valid_report = false;
                    break;
                }
            } else {
                if (last_visited < num) {
                    valid_report = false;
                    break;
                }
            }
            last_visited = num;
        }
        if (valid_report) {
            valid_reports += 1;
        }
    }
    try stdout.print("valid reports: {}\n", .{valid_reports});
    std.debug.assert(valid_reports == solution);
}

fn part_two(alloc: std.mem.Allocator) !void {
    const solution: usize = 604;
    var r_iter = std.mem.tokenizeScalar(u8, input, '\n');
    const stdout = std.io.getStdOut().writer();
    var valid_reports: usize = 0;

    while (r_iter.next()) |report| {
        var valid_report = true;
        var l_iter = std.mem.tokenizeScalar(u8, report, ' ');
        var levels = std.ArrayList(isize).init(alloc);
        defer levels.deinit();
        while (l_iter.next()) |level| {
            const parsed_level = try std.fmt.parseInt(isize, level, 10);
            try levels.append(parsed_level);
        }
        var last_visited: isize = levels.items[0];

        //First check
        for (levels.items[1..]) |level| {
            const is_asc = levels.items[0] < levels.items[1];
            const diff = @abs(last_visited - level);
            if (diff < 1 or diff > 3) {
                valid_report = false;
                break;
            }
            if (is_asc) {
                if (last_visited > level) {
                    valid_report = false;
                    break;
                }
            } else {
                if (last_visited < level) {
                    valid_report = false;
                    break;
                }
            }
            last_visited = level;
        }
        if (valid_report) {
            valid_reports += 1;
        }

        // Toleration checks
        if (!valid_report) {
            for (0..levels.items.len) |i| {
                var levels_clone = try levels.clone();
                _ = levels_clone.orderedRemove(i);
                last_visited = levels_clone.items[0];
                valid_report = true;
                const is_asc = levels_clone.items[0] < levels_clone.items[1];

                for (levels_clone.items[1..]) |level| {
                    const diff = @abs(last_visited - level);
                    if (diff < 1 or diff > 3) {
                        valid_report = false;
                        break;
                    }
                    if (is_asc) {
                        if (last_visited > level) {
                            valid_report = false;
                            break;
                        }
                    } else {
                        if (last_visited < level) {
                            valid_report = false;
                            break;
                        }
                    }
                    last_visited = level;
                }
                if (valid_report) {
                    valid_reports += 1;
                    break;
                }
            }
        }
    }
    try stdout.print("valid reports: {}\n", .{valid_reports});
    std.debug.assert(valid_reports == solution);
}

pub fn init() Puzzle {
    return .{
        .problem = problem,
        .part_one = part_one,
        .part_two = part_two,
    };
}
