const Puzzle = @import("../Puzzle.zig");
const Self = @This();
const input = @embedFile("input.txt");
const print = std.debug.print;
const std = @import("std");

const problem =
    \\ --- Day 7: Bridge Repair ---
    \\ 
    \\ The Historians take you to a familiar rope bridge over a river in the middle of a jungle. The Chief isn't on this side of the bridge, though; maybe he's on the other side?
    \\ 
    \\ When you go to cross the bridge, you notice a group of engineers trying to repair it. (Apparently, it breaks pretty frequently.) You won't be able to cross until it's fixed.
    \\ 
    \\ You ask how long it'll take; the engineers tell you that it only needs final calibrations, but some young elephants were playing nearby and stole all the operators from their calibration equations! They could finish the calibrations if only someone could determine which test values could possibly be produced by placing any combination of operators into their calibration equations (your puzzle input).
    \\ 
    \\ For example:
    \\ 
    \\ 190: 10 19
    \\ 3267: 81 40 27
    \\ 83: 17 5
    \\ 156: 15 6
    \\ 7290: 6 8 6 15
    \\ 161011: 16 10 13
    \\ 192: 17 8 14
    \\ 21037: 9 7 18 13
    \\ 292: 11 6 16 20
    \\ 
    \\ Each line represents a single equation. The test value appears before the colon on each line; it is your job to determine whether the remaining numbers can be combined with operators to produce the test value.
    \\ 
    \\ Operators are always evaluated left-to-right, not according to precedence rules. Furthermore, numbers in the equations cannot be rearranged. Glancing into the jungle, you can see elephants holding two different types of operators: add (+) and multiply (*).
    \\ 
    \\ Only three of the above equations can be made true by inserting operators:
    \\ 
    \\     190: 10 19 has only one position that accepts an operator: between 10 and 19. Choosing + would give 29, but choosing * would give the test value (10 * 19 = 190).
    \\     3267: 81 40 27 has two positions for operators. Of the four possible configurations of the operators, two cause the right side to match the test value: 81 + 40 * 27 and 81 * 40 + 27 both equal 3267 (when evaluated left-to-right)!
    \\     292: 11 6 16 20 can be solved in exactly one way: 11 + 6 * 16 + 20.
    \\ 
    \\ The engineers just need the total calibration result, which is the sum of the test values from just the equations that could possibly be true. In the above example, the sum of the test values for the three equations listed above is 3749.
    \\ 
    \\ Determine which equations could possibly be true. What is their total calibration result?
    \\ 
    \\ --- Part Two ---
    \\ 
    \\ The engineers seem concerned; the total calibration result you gave them is nowhere close to being within safety tolerances. Just then, you spot your mistake: some well-hidden elephants are holding a third type of operator.
    \\ 
    \\ The concatenation operator (||) combines the digits from its left and right inputs into a single number. For example, 12 || 345 would become 12345. All operators are still evaluated left-to-right.
    \\ 
    \\ Now, apart from the three equations that could be made true using only addition and multiplication, the above example has three more equations that can be made true by inserting operators:
    \\ 
    \\     156: 15 6 can be made true through a single concatenation: 15 || 6 = 156.
    \\     7290: 6 8 6 15 can be made true using 6 * 8 || 6 * 15.
    \\     192: 17 8 14 can be made true using 17 || 8 + 14.
    \\ 
    \\ Adding up all six test values (the three that could be made before using only + and * plus the new three that can now be made by also using ||) produces the new total calibration result of 11387.
    \\ 
    \\ Using your new knowledge of elephant hiding spots, determine which equations could possibly be true. What is their total calibration result?
;

fn part_one(alloc: std.mem.Allocator) !void {
    const stdout = std.io.getStdOut().writer();
    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var calibration: usize = 0;

    while (iter.next()) |test_row| {
        var test_arr = std.ArrayList(usize).init(alloc);
        defer test_arr.deinit();
        var test_iter = std.mem.tokenizeScalar(u8, test_row, ':');
        const test_value = try std.fmt.parseUnsigned(usize, test_iter.next() orelse unreachable, 10);
        var equation = std.mem.tokenizeScalar(u8, test_iter.next() orelse unreachable, ' ');
        while (equation.next()) |value| {
            try test_arr.append(try std.fmt.parseUnsigned(usize, value, 10));
        }
        const operations = std.math.shl(usize, 1, test_arr.items.len) - 1;
        for (0..operations) |i| {
            var result = test_arr.items[0];
            for (1..test_arr.items.len) |j| {
                const op = std.math.shr(usize, i, j) & 1;
                if (op == 1) {
                    result += test_arr.items[j];
                } else {
                    result *= test_arr.items[j];
                }
            }
            if (result == test_value) {
                calibration += test_value;
                break;
            }
        }
    }
    try stdout.print("calibrations: {}\n", .{calibration});
}

pub fn generatePermutations(allocator: std.mem.Allocator, elements: []const u8, target_length: usize) ![][]const u8 {
    const total = std.math.pow(usize, elements.len, target_length);
    var result = std.ArrayList([]const u8).init(allocator);
    errdefer {
        for (result.items) |item| allocator.free(item);
        result.deinit();
    }
    try result.ensureTotalCapacity(total);
    var current = try allocator.alloc(u8, target_length);
    defer allocator.free(current);
    var i: usize = 0;
    while (i < total) : (i += 1) {
        var num = i;
        var pos = target_length;
        while (pos > 0) {
            pos -= 1;
            const idx = num % elements.len;
            current[pos] = elements[idx];
            num /= elements.len;
        }
        const perm = try allocator.dupe(u8, current);
        try result.append(perm);
    }
    return try result.toOwnedSlice();
}

fn part_two(_: std.mem.Allocator) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("calibrations: TODO\n", .{});
}

pub fn init() Puzzle {
    return .{
        .problem = problem,
        .part_one = part_one,
        .part_two = part_two,
    };
}
