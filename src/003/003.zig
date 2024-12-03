const Puzzle = @import("../Puzzle.zig");
const Self = @This();
const input = @embedFile("input.txt");
const print = std.debug.print;
const std = @import("std");

const problem =
    \\ --- Day 3: Mull It Over ---
    \\ 
    \\ "Our computers are having issues, so I have no idea if we have any Chief Historians in stock! You're welcome to check the warehouse, though," says the mildly flustered shopkeeper at the North Pole Toboggan Rental Shop. The Historians head out to take a look.
    \\ 
    \\ The shopkeeper turns to you. "Any chance you can see why our computers are having issues again?"
    \\ 
    \\ The computer appears to be trying to run a program, but its memory (your puzzle input) is corrupted. All of the instructions have been jumbled up!
    \\ 
    \\ It seems like the goal of the program is just to multiply some numbers. It does that with instructions like mul(X,Y), where X and Y are each 1-3 digit numbers. For instance, mul(44,46) multiplies 44 by 46 to get a result of 2024. Similarly, mul(123,4) would multiply 123 by 4.
    \\ 
    \\ However, because the program's memory has been corrupted, there are also many invalid characters that should be ignored, even if they look like part of a mul instruction. Sequences like mul(4*, mul(6,9!, ?(12,34), or mul ( 2 , 4 ) do nothing.
    \\ 
    \\ For example, consider the following section of corrupted memory:
    \\ 
    \\ xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
    \\ 
    \\ Only the four highlighted sections are real mul instructions. Adding up the result of each instruction produces 161 (2*4 + 5*5 + 11*8 + 8*5).
    \\ 
    \\ Scan the corrupted memory for uncorrupted mul instructions. What do you get if you add up all of the results of the multiplications?
    \\ 
    \\ --- Part Two ---
    \\ 
    \\ As you scan through the corrupted memory, you notice that some of the conditional statements are also still intact. If you handle some of the uncorrupted conditional statements in the program, you might be able to get an even more accurate result.
    \\ 
    \\ There are two new instructions you'll need to handle:
    \\ 
    \\     The do() instruction enables future mul instructions.
    \\     The don't() instruction disables future mul instructions.
    \\ 
    \\ Only the most recent do() or don't() instruction applies. At the beginning of the program, mul instructions are enabled.
    \\ 
    \\ For example:
    \\ 
    \\ xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
    \\ 
    \\ This corrupted memory is similar to the example from before, but this time the mul(5,5) and mul(11,8) instructions are disabled because there is a don't() instruction before them. The other mul instructions function normally, including the one at the end that gets re-enabled by a do() instruction.
    \\ 
    \\ This time, the sum of the results is 48 (2*4 + 8*5).
    \\ 
    \\ Handle the new instructions; what do you get if you add up all of the results of just the enabled multiplications?
;

fn part_one(alloc: std.mem.Allocator) !void {
    const stdout = std.io.getStdOut().writer();
    const solution: usize = 181345830;
    var result: usize = 0;
    var tokens = std.ArrayList(u8).init(alloc);
    defer tokens.deinit();

    for (input) |char| {
        switch (char) {
            'm' => {
                if (tokens.getLastOrNull() != null) {
                    tokens.clearRetainingCapacity();
                }
                try tokens.append('m');
            },
            'u' => {
                if (tokens.getLastOrNull()) |token| {
                    if (token == 'm') {
                        try tokens.append('u');
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            'l' => {
                if (tokens.getLastOrNull()) |token| {
                    if (token == 'u') {
                        try tokens.append('l');
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            '(' => {
                if (tokens.getLastOrNull()) |token| {
                    if (token == 'l') {
                        try tokens.append('(');
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            ')' => {
                if (tokens.getLastOrNull()) |token| {
                    if (std.ascii.isDigit(token)) {
                        try tokens.append(')');
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            ',' => {
                if (tokens.getLastOrNull()) |token| {
                    if (std.ascii.isDigit(token)) {
                        try tokens.append(',');
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            '0'...'9' => {
                if (tokens.getLastOrNull()) |token| {
                    if (token == '(' or
                        token == ',' or
                        std.ascii.isDigit(token))
                    {
                        try tokens.append(char);
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            else => {
                tokens.clearRetainingCapacity();
            },
        }
        if (tokens.getLastOrNull()) |token| {
            if (token == ')') {
                // remove 'mul('
                inline for (0..4) |_| {
                    _ = tokens.orderedRemove(0);
                }
                _ = tokens.pop(); // remove ')'
                var iter = std.mem.splitScalar(u8, tokens.items, ',');
                const raw_first = iter.next() orelse return error.Invalid;
                const raw_second = iter.next() orelse return error.Invalid;
                const first = try std.fmt.parseUnsigned(usize, raw_first, 10);
                const second = try std.fmt.parseUnsigned(usize, raw_second, 10);
                const mul = first * second;
                result += mul;
                tokens.clearRetainingCapacity();
            }
        }
    }
    try stdout.print("mul: {}\n", .{result});
    std.debug.assert(result == solution);
}

fn part_two(alloc: std.mem.Allocator) !void {
    const solution: usize = 98729041;
    const stdout = std.io.getStdOut().writer();
    var result: usize = 0;
    var tokens = std.ArrayList(u8).init(alloc);
    defer tokens.deinit();
    var do = true;

    for (input, 0..) |char, i| {
        switch (char) {
            'm' => {
                if (tokens.getLastOrNull() != null) {
                    tokens.clearRetainingCapacity();
                }
                try tokens.append('m');
            },
            'u' => {
                if (tokens.getLastOrNull()) |token| {
                    if (token == 'm') {
                        try tokens.append('u');
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            'l' => {
                if (tokens.getLastOrNull()) |token| {
                    if (token == 'u') {
                        try tokens.append('l');
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            '(' => {
                if (tokens.getLastOrNull()) |token| {
                    if (token == 'l') {
                        try tokens.append('(');
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            ')' => {
                if (tokens.getLastOrNull()) |token| {
                    if (std.ascii.isDigit(token)) {
                        try tokens.append(')');
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            ',' => {
                if (tokens.getLastOrNull()) |token| {
                    if (std.ascii.isDigit(token)) {
                        try tokens.append(',');
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            '0'...'9' => {
                if (tokens.getLastOrNull()) |token| {
                    if (token == '(' or
                        token == ',' or
                        std.ascii.isDigit(token))
                    {
                        try tokens.append(char);
                    } else {
                        tokens.clearRetainingCapacity();
                    }
                }
            },
            'd' => {
                const sliced = input[i..];
                if (std.mem.startsWith(u8, sliced, "do()")) {
                    do = true;
                } else if (std.mem.startsWith(u8, sliced, "don't()")) {
                    do = false;
                }
            },
            else => {
                tokens.clearRetainingCapacity();
            },
        }
        if (tokens.getLastOrNull()) |token| {
            if (token == ')') {
                if (do) {
                    // remove 'mul('
                    inline for (0..4) |_| {
                        _ = tokens.orderedRemove(0);
                    }
                    _ = tokens.pop(); // remove ')'
                    var iter = std.mem.splitScalar(u8, tokens.items, ',');
                    const raw_first = iter.next() orelse return error.Invalid;
                    const raw_second = iter.next() orelse return error.Invalid;
                    const first = try std.fmt.parseUnsigned(usize, raw_first, 10);
                    const second = try std.fmt.parseUnsigned(usize, raw_second, 10);
                    const mul = first * second;
                    result += mul;
                }
                tokens.clearRetainingCapacity();
            }
        }
    }
    try stdout.print("mul: {}\n", .{result});
    std.debug.assert(result == solution);
}

pub fn init() Puzzle {
    return .{
        .problem = problem,
        .part_one = part_one,
        .part_two = part_two,
    };
}
