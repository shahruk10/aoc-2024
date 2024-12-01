const std = @import("std");

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    const N = comptime 1000;
    var left_list: [N]i32 = undefined;
    var right_list: [N]i32 = undefined;

    var lines = std.mem.tokenizeAny(u8, data, "\n");
    var n: usize = 0;

    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeAny(u8, line, " ");

        left_list[n] = try std.fmt.parseInt(i32, numbers.next().?, 10);
        right_list[n] = try std.fmt.parseInt(i32, numbers.next().?, 10);
        n += 1;
    }

    std.sort.block(i32, left_list[0..n], {}, std.sort.asc(i32));
    std.sort.block(i32, right_list[0..n], {}, std.sort.asc(i32));

    var ans_part1: u32 = 0;
    var ans_part2: u64 = 0;

    for (0..n) |i| {
        ans_part1 += @abs(left_list[i] - right_list[i]);

        var freq: i32 = 0;

        for (0..n) |j| {
            if (right_list[j] > left_list[i]) {
                break;
            }

            if (right_list[j] == left_list[i]) {
                freq += 1;
            }
        }

        ans_part2 += @intCast(freq * left_list[i]);
    }

    std.debug.print("part 1: sum of distances = {d}\n", .{ans_part1});
    std.debug.print("part 2: similarity score = {d}\n", .{ans_part2});
}
