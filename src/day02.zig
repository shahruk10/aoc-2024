const std = @import("std");

const data = @embedFile("data/day02.txt");

const N = 10;

const Trend = enum {
    unknown,
    increasing,
    decreasing,
};

const Report = struct {
    levels: [N]i32 = undefined,
    num_levels: usize = 0,

    pub fn parse(self: *Report, level_data: []const u8) !void {
        var values = std.mem.tokenizeAny(u8, level_data, " ");

        self.num_levels = 0;

        while (values.next()) |val| {
            self.levels[self.num_levels] = try std.fmt.parseInt(i32, val, 10);
            self.num_levels += 1;
        }
    }

    pub fn check(self: *Report) struct { safe: bool, fault_location: usize } {
        var trend = Trend.unknown;

        for (1..self.num_levels) |i| {
            if (!self.levelsAreSafe(self.levels[i - 1], self.levels[i], &trend)) {
                return .{ .safe = false, .fault_location = i };
            }
        }

        return .{ .safe = true, .fault_location = undefined };
    }

    fn checkSkippingLevel(self: *Report, to_skip: usize) bool {
        var trend = Trend.unknown;

        for (1..self.num_levels) |i| {
            var a = i - 1;
            var b = i;

            if (a == to_skip) {
                if (a == 0) {
                    continue;
                }

                a -= 1;
            }

            if (b == to_skip) {
                b += 1;

                if (b >= self.num_levels) {
                    return true;
                }
            }

            if (!self.levelsAreSafe(self.levels[a], self.levels[b], &trend)) {
                return false;
            }
        }

        return true;
    }

    fn levelsAreSafe(_: *Report, l1: i32, l2: i32, current_trend: *Trend) bool {
        const delta = l2 - l1;
        const abs_delta = @abs(delta);

        const t = current_trend.*;

        if ((abs_delta > 3 or abs_delta < 1) or
            (t == Trend.decreasing and delta > 0) or
            (t == Trend.increasing and delta < 0))
        {
            return false;
        }

        // Set trend if it is unknown, and levels are safe.
        if (t == Trend.unknown) {
            current_trend.* = if (delta < 0) Trend.decreasing else Trend.increasing;
        }

        return true;
    }
};

pub fn main() !void {
    var lines = std.mem.tokenizeAny(u8, data, "\n");
    var report = Report{};

    var ans_part1: u32 = 0;
    var ans_part2: u32 = 0;

    while (lines.next()) |level_data| {
        try report.parse(level_data);

        const check = report.check();

        if (check.safe) {
            ans_part1 += 1;
            ans_part2 += 1;
            continue;
        }

        if (report.checkSkippingLevel(check.fault_location) or
            report.checkSkippingLevel(check.fault_location - 1) or
            report.checkSkippingLevel(check.fault_location - 2))
        {
            ans_part2 += 1;
        }
    }

    std.debug.print("day02\tpart 1\t{d}\n", .{ans_part1});
    std.debug.print("day01\tpart 2\t{d}\n", .{ans_part2});
}
