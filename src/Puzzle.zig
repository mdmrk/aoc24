const std = @import("std");

problem: []const u8,
run: *const fn (args: *std.process.ArgIterator) void,
