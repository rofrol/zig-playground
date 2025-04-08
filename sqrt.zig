// https://www.reddit.com/r/Zig/comments/1ivzd4a/comment/meadtlt/
const std = @import("std");
const math = std.math;
pub fn main() !void {
    const x: i64 = 10200;
    const sqrtx: i32 = @intFromFloat(math.sqrt(@as(f32, @floatFromInt(x))));
    std.debug.print("{d}",.{sqrtx});
}
