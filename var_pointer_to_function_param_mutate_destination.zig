const std = @import("std");
pub fn main() void {
    var n: u8 = 3;
    sth(&n);
    std.debug.print("{}", .{n});
}

fn sth(p: *u8) void {
    var a = p;
    a.* = 1;
}
