const std = @import("std");

const MaxParameters = 32;

const data = @embedFile("data/day07.txt");

const Op = enum(u8) {
    Concat = 0,
    Add = 1,
    Mul = 2,
};

const CalibrationTester = struct {
    sum_valid_equations: u64 = 0,
    op_at_pos: [MaxParameters]u8 = undefined,

    fn checkEquation(self: *CalibrationTester,  parameters: []const u64, invalid_ops: []const u8) void {
        const test_value = parameters[0];
        const num_args = parameters.len-1;
        self.resetCombos();

        // Testing parameters.
        const num_ops = std.meta.fields(Op).len;
        const num_combinations = std.math.pow(u64, num_ops, @intCast(num_args-1));
        const op_at_pos = self.op_at_pos[0..num_args-1]; 

        for(0..num_combinations) | _ | {
            if(self.comboIsInvalid(op_at_pos, invalid_ops)) {
                self.nextOpCombo();
                continue;
            }

            var sum: u64 = parameters[1];

            for (2..parameters.len, 0..num_args-1) |i, j | {
                const op: Op =  @enumFromInt(self.op_at_pos[j]);

                sum = switch (op) {
                    Op.Add => sum + parameters[i],
                    Op.Mul => sum * parameters[i],
                    Op.Concat => concat(sum, parameters[i]),
                };
            }

            if (sum == test_value) {
                self.sum_valid_equations += test_value;
                return;
            }

            self.nextOpCombo();
        }
    }

    fn resetCombos(self: *CalibrationTester) void {
        for (0..self.op_at_pos.len) | i | {
            self.op_at_pos[i] = 0;
        }
    }

    fn nextOpCombo(self: *CalibrationTester) void {
        for (0..self.op_at_pos.len) |i |  {
        self.op_at_pos[i] += 1;

        if (self.op_at_pos[i] >= std.meta.fields(Op).len) { 
            self.op_at_pos[i] = 0;
            continue;
        }

        return;
        
        }
    }

    fn comboIsInvalid(_: *CalibrationTester, ops: []const u8, invalid_ops: []const u8) bool {
        if (invalid_ops.len == 0 ) {
            return false;
        }

        for (ops) | op | {
            for (invalid_ops) |invalid_op | {
                if (op == invalid_op) {
                    return true;
                }
            }
        }

        return false;
    }
};

fn concat(x: u64, y: u64) u64 { 
    var pow: u64 = 10;

    while(y >= pow) {
        pow *= 10;
    }
    
    return x * pow + y;   
}

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var parameters: [MaxParameters]u64 = undefined;

    var c1 = CalibrationTester{};
var c2 = CalibrationTester{};

    var lines = std.mem.tokenizeAny(u8, data,  "\n");

    while(lines.next()) | line | {
        var n: usize = 0;
        var numbers = std.mem.tokenizeAny(u8, line, ": ");

        while(numbers.next()) | number | : ( n += 1 ){
            parameters[n] = try std.fmt.parseUnsigned(u64, number, 10);
        }

        c1.checkEquation(parameters[0..n], &[_]u8{0});
        c2.checkEquation(parameters[0..n], &[_]u8{});
    }

    std.debug.print("day01\tpart 1\t{d}\n", .{c1.sum_valid_equations});
    std.debug.print("day01\tpart 2\t{d}\n", .{c2.sum_valid_equations});
    std.debug.print("total time\t{}\n", .{std.fmt.fmtDuration(timer.read())});
}
