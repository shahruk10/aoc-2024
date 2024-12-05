const std = @import("std");

const data = @embedFile("data/day04.txt");

const SolverError = error{
    TargetSizeTooLarge,
    TargetPart2IsNotOddLengthed,
};

const Solver = struct {
    grid: []const u8 = undefined,
    rows: usize = undefined,
    cols: usize = undefined,

    buffer: [4]u8 = undefined,
    num_matches_part1: u32 = 0,
    num_matches_part2: u32 = 0,

    pub fn solve(
        self: *Solver,
        puzzle: []const u8,
        target_part1: []const u8,
        target_part2: []const u8,
    ) SolverError!void {
        if (@max(target_part1.len, target_part2.len) > self.buffer.len) {
            return SolverError.TargetSizeTooLarge;
        }

        if ((target_part2.len % 2) == 0) {
            return SolverError.TargetPart2IsNotOddLengthed;
        }

        self.grid = puzzle;
        self.cols = std.mem.indexOf(u8, puzzle, "\n").?;
        self.rows = puzzle.len / (self.cols + 1);

        self.num_matches_part1 = 0;
        self.num_matches_part2 = 0;

        for (0..self.rows) |i| {
            for (0..self.cols) |j| {
                self.scan(i, j, target_part1, target_part2);
            }
        }
    }

    fn scan(self: *Solver, i: usize, j: usize, target_part1: []const u8, target_part2: []const u8) void {
        self.scanPart1(i, j, target_part1);
        self.scanPart2(i, j, target_part2);
    }

    fn scanPart1(self: *Solver, i: usize, j: usize, target: []const u8) void {
        // Scanning cardinal directions and diagonals.
        if (self.isMatch(i, j, -1, 0, target)) self.num_matches_part1 += 1;
        if (self.isMatch(i, j, 1, 0, target)) self.num_matches_part1 += 1;
        if (self.isMatch(i, j, 0, -1, target)) self.num_matches_part1 += 1;
        if (self.isMatch(i, j, -1, -1, target)) self.num_matches_part1 += 1;
        if (self.isMatch(i, j, 1, -1, target)) self.num_matches_part1 += 1;
        if (self.isMatch(i, j, 0, 1, target)) self.num_matches_part1 += 1;
        if (self.isMatch(i, j, -1, 1, target)) self.num_matches_part1 += 1;
        if (self.isMatch(i, j, 1, 1, target)) self.num_matches_part1 += 1;
    }

    fn scanPart2(self: *Solver, i: usize, j: usize, target: []const u8) void {
        // Check whether current position matches the middle character of the target string.
        const m = (target.len - 1) / 2;
        if (self.grid[i * (self.cols + 1) + j ] != target [m]) {
            return;
        }  

        // Scanning diagonals in both directions.
        const a = self.isMatch(i - 1, j - 1, 1, 1, target);
        const b = self.isMatch(i + 1, j + 1, -1, -1, target);
        const c = self.isMatch(i - 1, j + 1, 1, -1, target);
        const d = self.isMatch(i + 1, j - 1, -1, 1, target);

        if ((a or b) and (c or d)) {
            self.num_matches_part2 += 1;
        }
    }

    fn isMatch(self: *Solver, x_start: usize, y_start: usize, x_step: i32, y_step: i32, target: []const u8) bool {
        var i: i32 = @intCast(x_start);
        var j: i32 = @intCast(y_start);
        const stride: i32 = @intCast(self.cols + 1);

        for (0..target.len) |u| {
            const v: usize = @intCast(i * stride + j);
            if (v >= self.grid.len) {
                return false;
            }

            self.buffer[u] = self.grid[v];
            i += x_step;
            j += y_step;
        }

        return std.mem.eql(u8, self.buffer[0..target.len], target);
    }
};

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var solver = Solver{};
    try solver.solve(data, "XMAS", "MAS");

    std.debug.print("day01\tpart 1\t{d}\n", .{solver.num_matches_part1});
    std.debug.print("day01\tpart 2\t{d}\n", .{solver.num_matches_part2});
    std.debug.print("total time\t{}\n", .{std.fmt.fmtDuration(timer.read())});
}
