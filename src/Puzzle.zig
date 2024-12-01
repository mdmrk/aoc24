const std = @import("std");

problem: []const u8,
run: *const fn (alloc: std.mem.Allocator) anyerror!void,
