//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://www.reddit.com/r/Zig/comments/107wh7a/running_a_zig_file_like_a_script/
const std = @import("std");
const math = std.math;
const testing = std.testing;

fn binarySearch(
    comptime T: type,
    key: anytype,
    items: []const T,
    context: anytype,
    comptime compareFn: fn (context: @TypeOf(context), key: @TypeOf(key), mid: T) math.Order,
) ?usize {
    var left: usize = 0;
    var right: usize = items.len;

    while (left < right) {
        const mid = left + (right - left) / 2;
        switch (compareFn(context, key, items[mid])) {
            .eq => return mid,
            .gt => left = mid + 1,
            .lt => right = mid,
        }
    }

    return null;
}

test {
    const S = struct {
        fn order_u32(context: void, lhs: u32, rhs: u32) math.Order {
            _ = context;
            return math.order(lhs, rhs);
        }
    };

    try testing.expectEqual(
        @as(?usize, 2),
        binarySearch(u32, @as(u32, 3), &[_]u32{ 1, 2, 3, 4, 5 }, {}, S.order_u32),
    );

    try testing.expectEqual(
        @as(?usize, 4),
        binarySearch(u32, @as(u32, 5), &[_]u32{ 1, 2, 3, 4, 5 }, {}, S.order_u32),
    );
}
