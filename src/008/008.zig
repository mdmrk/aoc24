const Puzzle = @import("../Puzzle.zig");
const Self = @This();
const input = @embedFile("input.txt");
const print = std.debug.print;
const std = @import("std");

const problem =
    \\ --- Day 8: Resonant Collinearity ---
    \\ 
    \\ You find yourselves on the roof of a top-secret Easter Bunny installation.
    \\ 
    \\ While The Historians do their thing, you take a look at the familiar huge antenna. Much to your surprise, it seems to have been reconfigured to emit a signal that makes people 0.1% more likely to buy Easter Bunny brand Imitation Mediocre Chocolate as a Christmas gift! Unthinkable!
    \\ 
    \\ Scanning across the city, you find that there are actually many such antennas. Each antenna is tuned to a specific frequency indicated by a single lowercase letter, uppercase letter, or digit. You create a map (your puzzle input) of these antennas. For example:
    \\ 
    \\ ............
    \\ ........0...
    \\ .....0......
    \\ .......0....
    \\ ....0.......
    \\ ......A.....
    \\ ............
    \\ ............
    \\ ........A...
    \\ .........A..
    \\ ............
    \\ ............
    \\ 
    \\ The signal only applies its nefarious effect at specific antinodes based on the resonant frequencies of the antennas. In particular, an antinode occurs at any point that is perfectly in line with two antennas of the same frequency - but only when one of the antennas is twice as far away as the other. This means that for any pair of antennas with the same frequency, there are two antinodes, one on either side of them.
    \\ 
    \\ So, for these two antennas with frequency a, they create the two antinodes marked with #:
    \\ 
    \\ ..........
    \\ ...#......
    \\ ..........
    \\ ....a.....
    \\ ..........
    \\ .....a....
    \\ ..........
    \\ ......#...
    \\ ..........
    \\ ..........
    \\ 
    \\ Adding a third antenna with the same frequency creates several more antinodes. It would ideally add four antinodes, but two are off the right side of the map, so instead it adds only two:
    \\ 
    \\ ..........
    \\ ...#......
    \\ #.........
    \\ ....a.....
    \\ ........a.
    \\ .....a....
    \\ ..#.......
    \\ ......#...
    \\ ..........
    \\ ..........
    \\ 
    \\ Antennas with different frequencies don't create antinodes; A and a count as different frequencies. However, antinodes can occur at locations that contain antennas. In this diagram, the lone antenna with frequency capital A creates no antinodes but has a lowercase-a-frequency antinode at its location:
    \\ 
    \\ ..........
    \\ ...#......
    \\ #.........
    \\ ....a.....
    \\ ........a.
    \\ .....a....
    \\ ..#.......
    \\ ......A...
    \\ ..........
    \\ ..........
    \\ 
    \\ The first example has antennas with two different frequencies, so the antinodes they create look like this, plus an antinode overlapping the topmost A-frequency antenna:
    \\ 
    \\ ......#....#
    \\ ...#....0...
    \\ ....#0....#.
    \\ ..#....0....
    \\ ....0....#..
    \\ .#....A.....
    \\ ...#........
    \\ #......#....
    \\ ........A...
    \\ .........A..
    \\ ..........#.
    \\ ..........#.
    \\ 
    \\ Because the topmost A-frequency antenna overlaps with a 0-frequency antinode, there are 14 total unique locations that contain an antinode within the bounds of the map.
    \\ 
    \\ Calculate the impact of the signal. How many unique locations within the bounds of the map contain an antinode?
    \\ 
    \\ --- Part Two ---
    \\ 
    \\ Watching over your shoulder as you work, one of The Historians asks if you took the effects of resonant harmonics into your calculations.
    \\ 
    \\ Whoops!
    \\ 
    \\ After updating your model, it turns out that an antinode occurs at any grid position exactly in line with at least two antennas of the same frequency, regardless of distance. This means that some of the new antinodes will occur at the position of each antenna (unless that antenna is the only one of its frequency).
    \\ 
    \\ So, these three T-frequency antennas now create many antinodes:
    \\ 
    \\ T....#....
    \\ ...T......
    \\ .T....#...
    \\ .........#
    \\ ..#.......
    \\ ..........
    \\ ...#......
    \\ ..........
    \\ ....#.....
    \\ ..........
    \\ 
    \\ In fact, the three T-frequency antennas are all exactly in line with two antennas, so they are all also antinodes! This brings the total number of antinodes in the above example to 9.
    \\ 
    \\ The original example now has 34 antinodes, including the antinodes that appear on every antenna:
    \\ 
    \\ ##....#....#
    \\ .#.#....0...
    \\ ..#.#0....#.
    \\ ..##...0....
    \\ ....0....#..
    \\ .#...#A....#
    \\ ...#..#.....
    \\ #....#.#....
    \\ ..#.....A...
    \\ ....#....A..
    \\ .#........#.
    \\ ...#......##
    \\ 
    \\ Calculate the impact of the signal using this updated model. How many unique locations within the bounds of the map contain an antinode?
;

fn part_one(alloc: std.mem.Allocator) !void {
    var antinodes_count: usize = 0;
    const stdout = std.io.getStdOut().writer();
    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var city_arr = std.ArrayList([]u8).init(alloc);
    defer city_arr.deinit();
    var antenas_arr = std.ArrayList(u8).init(alloc);
    defer antenas_arr.deinit();
    var antinodes_arr = std.ArrayList([]u8).init(alloc);
    defer antinodes_arr.deinit();

    while (iter.next()) |value| {
        const line = try alloc.dupe(u8, value);
        try city_arr.append(line);
        var anti_line = try alloc.alloc(u8, line.len);

        for (line, 0..) |char, i| {
            if (char != '.' and std.mem.indexOfScalar(u8, antenas_arr.items, char) == null) {
                try antenas_arr.append(char);
            }
            anti_line[i] = '.';
        }
        try antinodes_arr.append(anti_line);
    }
    const city = city_arr.items;
    const antinodes = antinodes_arr.items;

    for (city, 0..) |line, i| {
        for (line, 0..) |char, j| {
            if (char == '.') {
                continue;
            }
            for (city, 0..) |line2, m| {
                for (line2, 0..) |char2, n| {
                    if (m != i and n != j and char == char2) {
                        const i_i = @as(isize, @intCast(i));
                        const i_j = @as(isize, @intCast(j));
                        const i_m = @as(isize, @intCast(m));
                        const i_n = @as(isize, @intCast(n));
                        const ant1 = @Vector(2, isize){ i_i, i_j };
                        const ant2 = @Vector(2, isize){ i_m, i_n };

                        const vec = ant2 - ant1;

                        const antinode1 = ant1 - vec;
                        const antinode2 = ant2 + vec;

                        inline for ([_]@Vector(2, isize){ antinode1, antinode2 }) |antinode| {
                            const y = antinode[0];
                            const x = antinode[1];
                            if (y >= 0 and y < city.len and x >= 0 and x < city[0].len) {
                                antinodes[@intCast(y)][@intCast(x)] = '#';
                            }
                        }
                    }
                }
            }
        }
    }
    for (antinodes) |line| {
        antinodes_count += std.mem.count(u8, line, "#");
    }

    try stdout.print("antinodes: {}\n", .{antinodes_count});
}

fn part_two(alloc: std.mem.Allocator) !void {
    var antinodes_count: usize = 0;
    const stdout = std.io.getStdOut().writer();
    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var city_arr = std.ArrayList([]u8).init(alloc);
    defer city_arr.deinit();
    var antenas_arr = std.ArrayList(u8).init(alloc);
    defer antenas_arr.deinit();
    var antinodes_arr = std.ArrayList([]u8).init(alloc);
    defer antinodes_arr.deinit();

    while (iter.next()) |value| {
        const line = try alloc.dupe(u8, value);
        try city_arr.append(line);
        var anti_line = try alloc.alloc(u8, line.len);

        for (line, 0..) |char, i| {
            if (char != '.' and std.mem.indexOfScalar(u8, antenas_arr.items, char) == null) {
                try antenas_arr.append(char);
            }
            anti_line[i] = '.';
        }
        try antinodes_arr.append(anti_line);
    }
    const city = city_arr.items;
    const antinodes = antinodes_arr.items;

    for (city, 0..) |line, i| {
        for (line, 0..) |char, j| {
            if (char == '.') {
                continue;
            }
            for (city, 0..) |line2, m| {
                for (line2, 0..) |char2, n| {
                    if (m != i and n != j and char == char2) {
                        for (city, 0..) |_, y| {
                            for (0..city[0].len) |x| {
                                const x1 = @as(isize, @intCast(j));
                                const y1 = @as(isize, @intCast(i));
                                const x2 = @as(isize, @intCast(n));
                                const y2 = @as(isize, @intCast(m));
                                const x3 = @as(isize, @intCast(x));
                                const y3 = @as(isize, @intCast(y));

                                if ((y2 - y1) * (x3 - x2) == (y3 - y2) * (x2 - x1)) {
                                    antinodes[y][x] = '#';
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    for (antinodes) |line| {
        antinodes_count += std.mem.count(u8, line, "#");
    }

    try stdout.print("antinodes: {}\n", .{antinodes_count});
}

pub fn init() Puzzle {
    return .{
        .problem = problem,
        .part_one = part_one,
        .part_two = part_two,
    };
}
