const std = @import("std");

problem: []const u8,
part_one: *const fn (alloc: std.mem.Allocator) anyerror!void,
part_two: *const fn (alloc: std.mem.Allocator) anyerror!void,
