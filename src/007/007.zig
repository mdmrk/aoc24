const Puzzle = @import("../Puzzle.zig");
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

pub fn PermutationIterator(comptime T: type) type {
    return struct {
        elements: []const T,
        target_length: usize,
        current: []T,
        done: bool = false,

        const Self = @This();

        pub fn init(elements: []const T, target_length: usize, allocator: std.mem.Allocator) !Self {
            const current = try allocator.alloc(T, target_length);
            @memset(current, elements[0]);

            return Self{
                .elements = elements,
                .target_length = target_length,
                .current = current,
            };
        }

        pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
            allocator.free(self.current);
        }

        pub fn next(self: *Self) ?[]const T {
            if (self.done) return null;

            const result = self.current;

            var carry = true;
            for (0..self.target_length) |i| {
                if (carry) {
                    const idx = (std.mem.indexOfScalar(T, self.elements, self.current[self.target_length - 1 - i]) orelse 0) + 1;
                    if (idx < self.elements.len) {
                        self.current[self.target_length - 1 - i] = self.elements[idx];
                        carry = false;
                        break;
                    } else {
                        self.current[self.target_length - 1 - i] = self.elements[0];
                    }
                }
            }

            self.done = carry;

            return result;
        }
    };
}

fn part_two(alloc: std.mem.Allocator) !void {
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
        const values = test_arr.items;
        const operators = [_]u8{ '+', '*', '|' };
        var perm_iter = try PermutationIterator(u8).init(&operators, values.len - 1, alloc);
        defer perm_iter.deinit(alloc);
        // print("{any}\n", .{values});
        blk: while (perm_iter.next()) |perm| {
            // print("{s}\n", .{perm});
            var result = values[0];
            for (perm, 1..) |op, i| {
                switch (op) {
                    '+' => result += values[i],
                    '*' => result *= values[i],
                    '|' => {
                        var pow: usize = 10;
                        while (values[i] >= pow) : (pow *= 10) {
                            if (pow > test_value) break;
                        }
                        if (pow > test_value) continue :blk;
                        result = result * pow + values[i];
                    },
                    else => {},
                }
                if (result > test_value) {
                    continue :blk;
                }
                // print("op: {c}, {} - ", .{ op, result });
            }
            if (result == test_value) {
                calibration += test_value;
                break;
            }
        }
    }

    try stdout.print("calibrations: {}\n", .{calibration});
}

pub fn init() Puzzle {
    return .{
        .problem = problem,
        .part_one = part_one,
        .part_two = part_two,
    };
}
