const std = @import("std");

const data = @embedFile("data/day01.txt");

const N = 1000;

const Errors = error{
    CapacityExceeded,
};

const LocationCount = struct {
    id: i32,
    count: i32,
};

/// LocationList stores a list of location IDs, always maintaining the list in
/// an ascending order of IDs.
const LocationList = struct {
    ids: [N]i32 = undefined,
    len_ids: usize = 0,

    counts: [N]LocationCount = undefined,
    len_counts: usize = 0,

    /// Stores the given ID within the list of locations.
    pub fn store(self: *LocationList, id: i32) !void {
        if (self.len_ids >= N) {
            return Errors.CapacityExceeded;
        }

        self.storeID(id);
        self.updateCount(id);
    }

    /// Returns the number of times the given location ID appears within the list.
    pub fn getCount(self: *LocationList, id: i32) i32 {
        var a: usize = 0;
        var b: usize = self.len_counts;

        // Using binary search as count list is sorted by IDs.
        while (a < b) {
            const i = (a + b) / 2;

            if (self.counts[i].id < id) {
                a = i + 1;
            } else if (self.counts[i].id > id) {
                b = i;
            } else {
                return self.counts[i].count;
            }
        }

        return 0;
    }

    /// Computes the distance between location IDs of this list and the other provided list.
    pub fn computeDistance(self: *LocationList, other: *LocationList) u32 {
        var n: usize = self.len_ids;
        if (n > other.len_ids) {
            n = other.len_ids;
        }

        var sum_distance: u32 = 0;

        for (0..n) |i| {
            sum_distance += @abs(self.ids[i] - other.ids[i]);
        }

        return sum_distance;
    }

    /// Computes the similarity score between location IDs of this list and the other provided list.
    pub fn computeSimilarity(self: *LocationList, other: *LocationList) i32 {
        var sum_similarity: i32 = 0;

        for (0..self.len_ids) |i| {
            sum_similarity += (self.ids[i] * other.getCount(self.ids[i]));
        }

        return sum_similarity;
    }

    /// Stores the given ID in the list maintaining sorted order.
    fn storeID(self: *LocationList, id: i32) void {
        for (0..self.len_ids) |i| {
            if (id <= self.ids[i]) {
                shiftRightFrom(i, i32, self.ids[0 .. self.len_ids + 1]);
                self.ids[i] = id;
                self.len_ids += 1;

                return;
            }
        }

        self.ids[self.len_ids] = id;
        self.len_ids += 1;
    }

    /// Updates teh count for the given ID.
    fn updateCount(self: *LocationList, id: i32) void {
        for (0..self.len_counts) |i| {
            if (self.counts[i].id == id) {
                self.counts[i].count += 1;
                return;
            }

            if (id < self.counts[i].id) {
                shiftRightFrom(i, LocationCount, self.counts[0 .. self.len_counts + 1]);
                self.counts[i] = LocationCount{ .id = id, .count = 1 };
                self.len_counts += 1;

                return;
            }
        }

        self.counts[self.len_counts] = LocationCount{ .id = id, .count = 1 };
        self.len_counts += 1;
    }

    /// Shifts the given array one element to the right, starting at i'th index.
    fn shiftRightFrom(i: usize, comptime T: type, arr: []T) void {
        var j: usize = arr.len - 1;
        while (j >= i and j > 0) : (j -= 1) {
            arr[j] = arr[j - 1];
        }
    }
};

pub fn main() !void {
    var left_list = LocationList{};
    var right_list = LocationList{};

    var lines = std.mem.tokenizeAny(u8, data, "\n");

    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeAny(u8, line, " ");
        try left_list.store(try std.fmt.parseInt(i32, numbers.next().?, 10));
        try right_list.store(try std.fmt.parseInt(i32, numbers.next().?, 10));
    }

    const ans_part1 = left_list.computeDistance(&right_list);
    const ans_part2 = left_list.computeSimilarity(&right_list);

    std.debug.print("day01\tpart 1\t{d}\n", .{ans_part1});
    std.debug.print("day01\tpart 2\t{d}\n", .{ans_part2});
}
