const std = @import("std");
const Puzzle = @import("../Puzzle.zig");
const Self = @This();
const input = @embedFile("input.txt");
const print = std.debug.print;
const problem =
    \\ --- Day 13: Claw Contraption ---
    \\ 
    \\ Next up: the lobby of a resort on a tropical island. The Historians take a moment to admire the hexagonal floor tiles before spreading out.
    \\ 
    \\ Fortunately, it looks like the resort has a new arcade! Maybe you can win some prizes from the claw machines?
    \\ 
    \\ The claw machines here are a little unusual. Instead of a joystick or directional buttons to control the claw, these machines have two buttons labeled A and B. Worse, you can't just put in a token and play; it costs 3 tokens to push the A button and 1 token to push the B button.
    \\ 
    \\ With a little experimentation, you figure out that each machine's buttons are configured to move the claw a specific amount to the right (along the X axis) and a specific amount forward (along the Y axis) each time that button is pressed.
    \\ 
    \\ Each machine contains one prize; to win the prize, the claw must be positioned exactly above the prize on both the X and Y axes.
    \\ 
    \\ You wonder: what is the smallest number of tokens you would have to spend to win as many prizes as possible? You assemble a list of every machine's button behavior and prize location (your puzzle input). For example:
    \\ 
    \\ Button A: X+94, Y+34
    \\ Button B: X+22, Y+67
    \\ Prize: X=8400, Y=5400
    \\ 
    \\ Button A: X+26, Y+66
    \\ Button B: X+67, Y+21
    \\ Prize: X=12748, Y=12176
    \\ 
    \\ Button A: X+17, Y+86
    \\ Button B: X+84, Y+37
    \\ Prize: X=7870, Y=6450
    \\ 
    \\ Button A: X+69, Y+23
    \\ Button B: X+27, Y+71
    \\ Prize: X=18641, Y=10279
    \\ 
    \\ This list describes the button configuration and prize location of four different claw machines.
    \\ 
    \\ For now, consider just the first claw machine in the list:
    \\ 
    \\     Pushing the machine's A button would move the claw 94 units along the X axis and 34 units along the Y axis.
    \\     Pushing the B button would move the claw 22 units along the X axis and 67 units along the Y axis.
    \\     The prize is located at X=8400, Y=5400; this means that from the claw's initial position, it would need to move exactly 8400 units along the X axis and exactly 5400 units along the Y axis to be perfectly aligned with the prize in this machine.
    \\ 
    \\ The cheapest way to win the prize is by pushing the A button 80 times and the B button 40 times. This would line up the claw along the X axis (because 80*94 + 40*22 = 8400) and along the Y axis (because 80*34 + 40*67 = 5400). Doing this would cost 80*3 tokens for the A presses and 40*1 for the B presses, a total of 280 tokens.
    \\ 
    \\ For the second and fourth claw machines, there is no combination of A and B presses that will ever win a prize.
    \\ 
    \\ For the third claw machine, the cheapest way to win the prize is by pushing the A button 38 times and the B button 86 times. Doing this would cost a total of 200 tokens.
    \\ 
    \\ So, the most prizes you could possibly win is two; the minimum tokens you would have to spend to win all (two) prizes is 480.
    \\ 
    \\ You estimate that each button would need to be pressed no more than 100 times to win a prize. How else would someone be expected to play?
    \\ 
    \\ Figure out how to win as many prizes as possible. What is the fewest tokens you would have to spend to win all possible prizes?
    \\ 
    \\ --- Part Two ---
    \\ 
    \\ As you go to win the first prize, you discover that the claw is nowhere near where you expected it would be. Due to a unit conversion error in your measurements, the position of every prize is actually 10000000000000 higher on both the X and Y axis!
    \\ 
    \\ Add 10000000000000 to the X and Y position of every prize. After making this change, the example above would now look like this:
    \\ 
    \\ Button A: X+94, Y+34
    \\ Button B: X+22, Y+67
    \\ Prize: X=10000000008400, Y=10000000005400
    \\ 
    \\ Button A: X+26, Y+66
    \\ Button B: X+67, Y+21
    \\ Prize: X=10000000012748, Y=10000000012176
    \\ 
    \\ Button A: X+17, Y+86
    \\ Button B: X+84, Y+37
    \\ Prize: X=10000000007870, Y=10000000006450
    \\ 
    \\ Button A: X+69, Y+23
    \\ Button B: X+27, Y+71
    \\ Prize: X=10000000018641, Y=10000000010279
    \\ 
    \\ Now, it is only possible to win a prize on the second and fourth claw machines. Unfortunately, it will take many more than 100 presses to do so.
    \\ 
    \\ Using the corrected prize coordinates, figure out how to win as many prizes as possible. What is the fewest tokens you would have to spend to win all possible prizes?
;

fn part_one(_: std.mem.Allocator) !void {
    var tokens: usize = 0;
    const stdout = std.io.getStdOut().writer();
    const Coord = @Vector(2, isize);
    const Machine = struct {
        buttons: struct {
            a: Coord,
            b: Coord,
        },
        price: Coord,
    };

    var machine: Machine = undefined;
    var button_count: u8 = 0;
    var lines = std.mem.split(u8, input, "\n");

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        // Parse coordinates
        const x_start = std.mem.indexOf(u8, line, "X").? + 1;
        var x_end = x_start;
        while (x_end < line.len and line[x_end] != ',') : (x_end += 1) {}
        const x_str = line[x_start + 1 .. x_end];

        const y_start = std.mem.indexOf(u8, line, "Y").? + 1;
        var y_end = y_start;
        while (y_end < line.len and (line[y_end] != ',' and line[y_end] != '\n')) : (y_end += 1) {}
        const y_str = line[y_start + 1 .. y_end];

        const x = try std.fmt.parseInt(isize, x_str, 10);
        const y = try std.fmt.parseInt(isize, y_str, 10);
        const coord = Coord{ x, y };

        // Store coordinates and solve when we have a complete machine
        switch (button_count) {
            0 => {
                machine.buttons.a = coord;
                button_count = 1;
            },
            1 => {
                machine.buttons.b = coord;
                button_count = 2;
            },
            2 => {
                machine.price = coord;
                button_count = 0;

                // Solve this machine
                var a: usize = 0;
                outer: while (a <= 100) : (a += 1) {
                    var b: usize = 0;
                    while (b <= 100) : (b += 1) {
                        const pos = machine.buttons.a * @as(Coord, @splat(@as(isize, @intCast(a)))) +
                            machine.buttons.b * @as(Coord, @splat(@as(isize, @intCast(b))));

                        if (pos[0] == machine.price[0] and pos[1] == machine.price[1]) {
                            tokens += a * 3 + b;
                            break :outer;
                        }
                    }
                }
            },
            else => unreachable,
        }
    }

    try stdout.print("tokens: {}\n", .{tokens});
}

fn part_two(_: std.mem.Allocator) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("tokens: TODO\n", .{});
}

pub fn init() Puzzle {
    return .{
        .problem = problem,
        .part_one = part_one,
        .part_two = part_two,
    };
}
