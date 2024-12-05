const std = @import("std");

const data = @embedFile("data/day05.txt");

const MaxPageNumber = 256;
const MaxUpdatesToPrint = 256;

const QueueError = error{
    ExceededMaxPageNumber,
};

const PrintQueue = struct {
    ordering_rules: [MaxPageNumber + 1][MaxPageNumber + 1]bool = undefined,
    updates_to_print: std.BoundedArray(std.BoundedArray(u8, MaxPageNumber + 1), MaxUpdatesToPrint) = undefined,

    check_sum_part1: u32 = 0,
    check_sum_part2: u32 = 0,

    pub fn load(self: *PrintQueue, input: []const u8) !void {
        var in_rules_section: bool = true;
        var lines = std.mem.tokenizeAny(u8, input, "\n");

        while (lines.next()) |line| {
            if (in_rules_section) {
                if (std.mem.indexOf(u8, line, ",")) |_| {
                    in_rules_section = false;
                }
            }

            if (in_rules_section) {
                var numbers = std.mem.tokenizeAny(u8, line, "|");
                const a = try std.fmt.parseUnsigned(u8, numbers.next().?, 10);
                const b = try std.fmt.parseUnsigned(u8, numbers.next().?, 10);

                if (a >= MaxPageNumber or b >= MaxPageNumber) {
                    return QueueError.ExceededMaxPageNumber;
                }

                self.ordering_rules[a][b] = true;
                continue;
            }

            var numbers = std.mem.tokenizeAny(u8, line, ",");

            const update = try self.updates_to_print.addOne();
            while (numbers.next()) |number| {
                try update.append(try std.fmt.parseUnsigned(u8, number, 10));
            }
        }
    }

    pub fn print(self: *PrintQueue) void {
        for (self.updates_to_print.slice()) |update| {
            const pages = @constCast(update.slice());
            var correctly_ordered: bool = true;

            for (0..pages.len - 1, 1..pages.len) |i, j| {
                if (comparePages(self.ordering_rules, pages[i], pages[j])) {
                    continue;
                }

                correctly_ordered = false;
                break;
            }

            var m = (pages.len - 1) / 2;
            if (pages.len % 2 == 0) {
                m = pages.len / 2;
            }

            if (correctly_ordered) {
                self.check_sum_part1 += pages[m];
                continue;
            }

            std.sort.block(u8, pages, self.ordering_rules, comparePages);
            self.check_sum_part2 += pages[m];
        }
    }
};

pub fn comparePages(ordering_rules: [MaxPageNumber + 1][MaxPageNumber + 1]bool, a: u8, b: u8) bool {
    return ordering_rules[a][b];
}

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var q = PrintQueue{};
    try q.load(data);
    q.print();

    std.debug.print("day01\tpart 1\t{d}\n", .{q.check_sum_part1});
    std.debug.print("day01\tpart 2\t{d}\n", .{q.check_sum_part2});
    std.debug.print("total time\t{}\n", .{std.fmt.fmtDuration(timer.read())});
}
