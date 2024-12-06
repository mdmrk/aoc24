const Puzzle = @import("../Puzzle.zig");
const Self = @This();
const input = @embedFile("input.txt");
const print = std.debug.print;
const std = @import("std");

const problem =
    \\ --- Day 6: Guard Gallivant ---
    \\ 
    \\ The Historians use their fancy device again, this time to whisk you all away to the North Pole prototype suit manufacturing lab... in the year 1518! It turns out that having direct access to history is very convenient for a group of historians.
    \\ 
    \\ You still have to be careful of time paradoxes, and so it will be important to avoid anyone from 1518 while The Historians search for the Chief. Unfortunately, a single guard is patrolling this part of the lab.
    \\ 
    \\ Maybe you can work out where the guard will go ahead of time so that The Historians can search safely?
    \\ 
    \\ You start by making a map (your puzzle input) of the situation. For example:
    \\ 
    \\ ....#.....
    \\ .........#
    \\ ..........
    \\ ..#.......
    \\ .......#..
    \\ ..........
    \\ .#..^.....
    \\ ........#.
    \\ #.........
    \\ ......#...
    \\ 
    \\ The map shows the current position of the guard with ^ (to indicate the guard is currently facing up from the perspective of the map). Any obstructions - crates, desks, alchemical reactors, etc. - are shown as #.
    \\ 
    \\ Lab guards in 1518 follow a very strict patrol protocol which involves repeatedly following these steps:
    \\ 
    \\     If there is something directly in front of you, turn right 90 degrees.
    \\     Otherwise, take a step forward.
    \\ 
    \\ Following the above protocol, the guard moves up several times until she reaches an obstacle (in this case, a pile of failed suit prototypes):
    \\ 
    \\ ....#.....
    \\ ....^....#
    \\ ..........
    \\ ..#.......
    \\ .......#..
    \\ ..........
    \\ .#........
    \\ ........#.
    \\ #.........
    \\ ......#...
    \\ 
    \\ Because there is now an obstacle in front of the guard, she turns right before continuing straight in her new facing direction:
    \\ 
    \\ ....#.....
    \\ ........>#
    \\ ..........
    \\ ..#.......
    \\ .......#..
    \\ ..........
    \\ .#........
    \\ ........#.
    \\ #.........
    \\ ......#...
    \\ 
    \\ Reaching another obstacle (a spool of several very long polymers), she turns right again and continues downward:
    \\ 
    \\ ....#.....
    \\ .........#
    \\ ..........
    \\ ..#.......
    \\ .......#..
    \\ ..........
    \\ .#......v.
    \\ ........#.
    \\ #.........
    \\ ......#...
    \\ 
    \\ This process continues for a while, but the guard eventually leaves the mapped area (after walking past a tank of universal solvent):
    \\ 
    \\ ....#.....
    \\ .........#
    \\ ..........
    \\ ..#.......
    \\ .......#..
    \\ ..........
    \\ .#........
    \\ ........#.
    \\ #.........
    \\ ......#v..
    \\ 
    \\ By predicting the guard's route, you can determine which specific positions in the lab will be in the patrol path. Including the guard's starting position, the positions visited by the guard before leaving the area are marked with an X:
    \\ 
    \\ ....#.....
    \\ ....XXXXX#
    \\ ....X...X.
    \\ ..#.X...X.
    \\ ..XXXXX#X.
    \\ ..X.X.X.X.
    \\ .#XXXXXXX.
    \\ .XXXXXXX#.
    \\ #XXXXXXX..
    \\ ......#X..
    \\ 
    \\ In this example, the guard will visit 41 distinct positions on your map.
    \\ 
    \\ Predict the path of the guard. How many distinct positions will the guard visit before leaving the mapped area?
    \\ 
    \\ --- Part Two ---
    \\ 
    \\ While The Historians begin working around the guard's patrol route, you borrow their fancy device and step outside the lab. From the safety of a supply closet, you time travel through the last few months and record the nightly status of the lab's guard post on the walls of the closet.
    \\ 
    \\ Returning after what seems like only a few seconds to The Historians, they explain that the guard's patrol area is simply too large for them to safely search the lab without getting caught.
    \\ 
    \\ Fortunately, they are pretty sure that adding a single new obstruction won't cause a time paradox. They'd like to place the new obstruction in such a way that the guard will get stuck in a loop, making the rest of the lab safe to search.
    \\ 
    \\ To have the lowest chance of creating a time paradox, The Historians would like to know all of the possible positions for such an obstruction. The new obstruction can't be placed at the guard's starting position - the guard is there right now and would notice.
    \\ 
    \\ In the above example, there are only 6 different positions where a new obstruction would cause the guard to get stuck in a loop. The diagrams of these six situations use O to mark the new obstruction, | to show a position where the guard moves up/down, - to show a position where the guard moves left/right, and + to show a position where the guard moves both up/down and left/right.
    \\ 
    \\ Option one, put a printing press next to the guard's starting position:
    \\ 
    \\ ....#.....
    \\ ....+---+#
    \\ ....|...|.
    \\ ..#.|...|.
    \\ ....|..#|.
    \\ ....|...|.
    \\ .#.O^---+.
    \\ ........#.
    \\ #.........
    \\ ......#...
    \\ 
    \\ Option two, put a stack of failed suit prototypes in the bottom right quadrant of the mapped area:
    \\ 
    \\ ....#.....
    \\ ....+---+#
    \\ ....|...|.
    \\ ..#.|...|.
    \\ ..+-+-+#|.
    \\ ..|.|.|.|.
    \\ .#+-^-+-+.
    \\ ......O.#.
    \\ #.........
    \\ ......#...
    \\ 
    \\ Option three, put a crate of chimney-squeeze prototype fabric next to the standing desk in the bottom right quadrant:
    \\ 
    \\ ....#.....
    \\ ....+---+#
    \\ ....|...|.
    \\ ..#.|...|.
    \\ ..+-+-+#|.
    \\ ..|.|.|.|.
    \\ .#+-^-+-+.
    \\ .+----+O#.
    \\ #+----+...
    \\ ......#...
    \\ 
    \\ Option four, put an alchemical retroencabulator near the bottom left corner:
    \\ 
    \\ ....#.....
    \\ ....+---+#
    \\ ....|...|.
    \\ ..#.|...|.
    \\ ..+-+-+#|.
    \\ ..|.|.|.|.
    \\ .#+-^-+-+.
    \\ ..|...|.#.
    \\ #O+---+...
    \\ ......#...
    \\ 
    \\ Option five, put the alchemical retroencabulator a bit to the right instead:
    \\ 
    \\ ....#.....
    \\ ....+---+#
    \\ ....|...|.
    \\ ..#.|...|.
    \\ ..+-+-+#|.
    \\ ..|.|.|.|.
    \\ .#+-^-+-+.
    \\ ....|.|.#.
    \\ #..O+-+...
    \\ ......#...
    \\ 
    \\ Option six, put a tank of sovereign glue right next to the tank of universal solvent:
    \\ 
    \\ ....#.....
    \\ ....+---+#
    \\ ....|...|.
    \\ ..#.|...|.
    \\ ..+-+-+#|.
    \\ ..|.|.|.|.
    \\ .#+-^-+-+.
    \\ .+----++#.
    \\ #+----++..
    \\ ......#O..
    \\ 
    \\ It doesn't really matter what you choose to use as an obstacle so long as you and The Historians can put it into position without the guard noticing. The important thing is having enough options that you can find one that minimizes time paradoxes, and in this example, there are 6 different positions you could choose.
    \\ 
    \\ You need to get the guard stuck in a loop by adding a single new obstruction. How many different positions could you choose for this obstruction?
;

fn part_one(alloc: std.mem.Allocator) !void {
    var visited: usize = 0;
    const stdout = std.io.getStdOut().writer();
    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var tiles_arr = std.ArrayList([]u8).init(alloc);
    defer tiles_arr.deinit();
    var visited_tiles_arr = std.ArrayList([]u8).init(alloc);
    defer visited_tiles_arr.deinit();

    while (iter.next()) |value| {
        const mutable_line = try alloc.dupe(u8, value);
        const line = try alloc.dupe(u8, value);
        try tiles_arr.append(line);
        try visited_tiles_arr.append(mutable_line);
    }
    const tiles = tiles_arr.items;
    var visited_tiles = visited_tiles_arr.items;

    // guard initial position
    var guard_pos: [2]usize = undefined;
    blk: for (tiles, 0..) |line, i| {
        for (line, 0..) |_, j| {
            if (tiles[i][j] == '^') {
                guard_pos = .{ i, j };
                break :blk;
            }
        }
    }

    // move guard
    blk: while (true) {
        const i = guard_pos[0];
        const j = guard_pos[1];

        visited_tiles[i][j] = 'X';
        if (tiles[i][j] == '^') {
            if (i == 0) {
                break :blk;
            }
            if (tiles[i - 1][j] == '#') {
                tiles[i][j] = '>';
            } else {
                tiles[i - 1][j] = '^';
                tiles[i][j] = '.';
                guard_pos[0] -= 1;
            }
        } else if (tiles[i][j] == '>') {
            if (j == tiles[0].len - 1) {
                break :blk;
            }
            if (tiles[i][j + 1] == '#') {
                tiles[i][j] = 'v';
            } else {
                tiles[i][j + 1] = '>';
                tiles[i][j] = '.';
                guard_pos[1] += 1;
            }
        } else if (tiles[i][j] == 'v') {
            if (i == tiles.len - 1) {
                break :blk;
            }
            if (tiles[i + 1][j] == '#') {
                tiles[i][j] = '<';
            } else {
                tiles[i + 1][j] = 'v';
                tiles[i][j] = '.';
                guard_pos[0] += 1;
            }
        } else if (tiles[i][j] == '<') {
            if (j == 0) {
                break :blk;
            }
            if (tiles[i][j - 1] == '#') {
                tiles[i][j] = '^';
            } else {
                tiles[i][j - 1] = '<';
                tiles[i][j] = '.';
                guard_pos[1] -= 1;
            }
        }
    }
    for (visited_tiles) |row| {
        for (row) |cell| {
            if (cell == 'X') {
                visited += 1;
            }
        }
    }
    try stdout.print("visited: {}\n", .{visited});
}

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
};

fn get_direction_vector(dir: Direction) [2]isize {
    return switch (dir) {
        .Up => .{ -1, 0 },
        .Down => .{ 1, 0 },
        .Left => .{ 0, -1 },
        .Right => .{ 0, 1 },
    };
}

fn part_two(alloc: std.mem.Allocator) !void {
    const stdout = std.io.getStdOut().writer();
    var iter = std.mem.tokenizeScalar(u8, input, '\n');
    var tiles_arr = std.ArrayList([]u8).init(alloc);
    defer tiles_arr.deinit();
    var obstructions: usize = 0;

    while (iter.next()) |value| {
        const line = try alloc.dupe(u8, value);
        try tiles_arr.append(line);
    }
    const tiles = tiles_arr.items;

    // guard initial position
    var direction: Direction = .Up;
    var guard_pos: [2]usize = undefined;
    for (tiles, 0..) |row, i| {
        if (std.mem.indexOfScalar(u8, row, '^')) |j| {
            guard_pos = .{ i, j };
            break;
        }
    }

    // move guard
    const Seen = struct { i: usize, j: usize, dir: Direction };
    const guard_origin = guard_pos;
    var seen = std.ArrayList(Seen).init(alloc);
    for (0..tiles.len) |obs_i| {
        for (0..tiles[0].len) |obs_j| {
            const tile = tiles[obs_i][obs_j];
            if (tile == '#' or tile == '^') {
                continue;
            }
            defer tiles[obs_i][obs_j] = '.';
            defer guard_pos = guard_origin;
            defer direction = .Up;
            defer seen.clearRetainingCapacity();
            tiles[obs_i][obs_j] = '#';

            break_loop: {
                while (true) {
                    const i = guard_pos[0];
                    const j = guard_pos[1];
                    const direction_vector = get_direction_vector(direction);
                    {
                        const target_i = @as(isize, @intCast(i)) + direction_vector[0];
                        const target_j = @as(isize, @intCast(j)) + direction_vector[1];
                        if (target_i < 0 or target_j < 0 or target_i == tiles.len or target_j == tiles[0].len) {
                            break :break_loop;
                        }
                    }
                    const target_i: usize = @intCast(@as(isize, @intCast(i)) + direction_vector[0]);
                    const target_j: usize = @intCast(@as(isize, @intCast(j)) + direction_vector[1]);
                    const target_tile = tiles[target_i][target_j];
                    if (target_tile == '#') {
                        for (seen.items) |hit| {
                            if (hit.i == i and hit.j == j and hit.dir == direction) {
                                obstructions += 1;
                                break :break_loop;
                            }
                        }
                        try seen.append(.{
                            .i = i,
                            .j = j,
                            .dir = direction,
                        });
                        direction = switch (direction) {
                            .Up => .Right,
                            .Right => .Down,
                            .Down => .Left,
                            .Left => .Up,
                        };
                    } else {
                        guard_pos = .{ target_i, target_j };
                    }
                }
            }
        }
    }
    try stdout.print("obstructions: {}\n", .{obstructions});
}

pub fn init() Puzzle {
    return .{
        .problem = problem,
        .part_one = part_one,
        .part_two = part_two,
    };
}
