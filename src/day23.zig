const std = @import("std");

const data = @embedFile("data/day23.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    std.debug.print("day01\tpart 1\t{d}\n", .{});
    std.debug.print("day01\tpart 2\t{d}\n", .{});
    std.debug.print("total time\t{}\n", .{std.fmt.fmtDuration(timer.read())});
}
