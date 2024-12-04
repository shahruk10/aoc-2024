const std = @import("std");

const data = @embedFile("data/day03.txt");

const ParserError = error{
    UnexpectedEOF,
    InvalidMulInstruction,
    InvalidDigit,
    InvalidNumber,
    CantParseNumber,
};

const Parser = struct {
    data: []const u8 = undefined,
    current_pos: usize = 0,
    mul_enabled: bool = true,
    sum_part1: u64 = 0,
    sum_part2: u64 = 0,

    pub fn parse(self: *Parser, instructions: []const u8) void {
        self.data = instructions;
        self.current_pos = 0;
        self.mul_enabled = true;
        self.sum_part1 = 0;
        self.sum_part2 = 0;

        while (self.current_pos < self.data.len) {
            if (self.peek("do()")) {
                self.readMulEnabled();
                continue;
            }

            if (self.peek("don't()")) {
                self.readMulDisabled();
                continue;
            }

            if (self.peek("mul(") and self.readMul()) {
                continue;
            }

            self.current_pos += 1;
        }
    }

    fn peek(self: *Parser, str: []const u8) bool {
        if ((self.current_pos + str.len) > self.data.len) {
            return false;
        }

        const i = self.current_pos;
        const j = self.current_pos + str.len;

        return std.mem.eql(u8, self.data[i..j], str);
    }

    fn readMul(self: *Parser) bool {
        const org_pos = self.current_pos;
        self.current_pos += 4;

        const a = self.readNumber() catch {
            self.current_pos = org_pos;
            return false;
        };

        const b = self.readNumber() catch {
            self.current_pos = org_pos;
            return false;
        };

        if (self.data[self.current_pos - 1] != ')') {
            self.current_pos = org_pos;
            return false;
        }

        const prod = (a * b);

        self.sum_part1 += prod;
        if (self.mul_enabled) {
            self.sum_part2 += prod;
        }

        return true;
    }

    fn readNumber(self: *Parser) ParserError!u32 {
        const start_pos = self.current_pos;
        if (start_pos >= self.data.len) {
            return ParserError.UnexpectedEOF;
        }

        var i = start_pos;
        var end_pos: usize = start_pos;

        while (i < self.data.len) : (i += 1) {
            if (data[i] == ',' or data[i] == ')') {
                end_pos = i;
                break;
            }

            if (data[i] < '0' or data[i] > '9') {
                return ParserError.InvalidDigit;
            }
        }

        if (start_pos == end_pos) {
            return ParserError.InvalidNumber;
        }

        const number = std.fmt.parseInt(u32, self.data[start_pos..end_pos], 10) catch {
            return ParserError.CantParseNumber;
        };

        self.current_pos = end_pos + 1;

        return number;
    }

    fn readMulEnabled(self: *Parser) void {
        self.mul_enabled = true;
        self.current_pos += "do()".len;
    }

    fn readMulDisabled(self: *Parser) void {
        self.mul_enabled = false;
        self.current_pos += "don't()".len;
    }
};

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var parser = Parser{};

    parser.parse(data);

    std.debug.print("day01\tpart 1\t{d}\n", .{parser.sum_part1});
    std.debug.print("day01\tpart 2\t{d}\n", .{parser.sum_part2});
    std.debug.print("total time\t{}\n", .{std.fmt.fmtDuration(timer.read())});
}
