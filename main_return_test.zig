const std = @import("std");

pub fn main() !void {
    // defer will not be called if we use std.process.exit
    // https://www.reddit.com/r/Zig/comments/1eea56x/comment/lfephma/
    // to return specific number, we have to change return type of main to !u8
    // https://news.ycombinator.com/item?id=41918325
    defer std.debug.print("defer\n", .{});
    // std.process.exit(0);
}
