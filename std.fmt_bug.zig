const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    // A signed 3 formatted w/ "{d:0>4}" gives "00+3".
    // https://x.com/karlseguin/status/1792374097009357302
    const n: i32 = 3;
    print("{d:0>4}\n", .{n});
}
