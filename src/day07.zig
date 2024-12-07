const std = @import("std");

const MaxParameters = 32;

const data = @embedFile("data/day07.txt");

const Op = enum(u8) {
    Add = 0,
    Mul = 1,
    Concat = 2,
};

fn concat(x: u64, y: u64) u64 {
    inline for ([_]u64{ 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10, 1e11, 1e12, 1e13, 1e14, 1e15 }) |pow| {
        if (y < pow) {
            return x * pow + y;
        }
    }

    var pow: u64 = 1e16;
    while (y >= pow) pow *= 10;

    return x * pow + y;
}

const CalibrationTester = struct {
    allowed_ops: []const Op,
    sum_valid_equations: u64 = 0,
    sum_updated: bool = false,

    fn checkEquation(self: *CalibrationTester, test_value: u64, parameters: []const u64) bool {
        self.sum_updated = false;

        for (self.allowed_ops) |next_op| {
            self.evaluate(test_value, parameters[0], parameters[1..], next_op);
        }

        return self.sum_updated;
    }

    fn evaluate(self: *CalibrationTester, test_value: u64, sum: u64, parameters: []const u64, op: Op) void {
        if (sum > test_value) {
            return;
        }

        const next_param = parameters[0];

        const updated_sum = switch (op) {
            Op.Concat => concat(sum, next_param),
            Op.Mul => sum * next_param,
            Op.Add => sum + next_param,
        };

        if (parameters.len <= 1) {
            if (test_value == updated_sum and !self.sum_updated) {
                self.sum_valid_equations += test_value;
                self.sum_updated = true;
            }

            return;
        }

        for (self.allowed_ops) |next_op| {
            self.evaluate(test_value, updated_sum, parameters[1..], next_op);
        }
    }
};

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var c1 = CalibrationTester{ .allowed_ops = &[_]Op{ .Mul, .Add } };
    var c2 = CalibrationTester{ .allowed_ops = &[_]Op{ .Concat, .Mul, .Add } };

    var parameters: [MaxParameters]u64 = undefined;
    var lines = std.mem.tokenizeAny(u8, data, "\n");

    while (lines.next()) |line| {
        var n: usize = 0;
        var numbers = std.mem.tokenizeAny(u8, line, ": ");

        while (numbers.next()) |number| : (n += 1) {
            parameters[n] = try std.fmt.parseUnsigned(u64, number, 10);
        }

        if (c1.checkEquation(parameters[0], parameters[1..n])) {
            c2.sum_valid_equations += parameters[0];
        } else {
            _ = c2.checkEquation(parameters[0], parameters[1..n]);
        }
    }

    std.debug.print("day01\tpart 1\t{d}\n", .{c1.sum_valid_equations});
    std.debug.print("day01\tpart 2\t{d}\n", .{c2.sum_valid_equations});
    std.debug.print("total time\t{}\n", .{std.fmt.fmtDuration(timer.read())});
}
