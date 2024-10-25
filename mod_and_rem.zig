//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://www.reddit.com/r/Zig/comments/107wh7a/running_a_zig_file_like_a_script/

// https://www.mathworks.com/matlabcentral/answers/403870-difference-between-mod-and-rem-functions
// https://en.wikipedia.org/wiki/Modulo
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
pub fn main() void {
    var x: i8 = 4;
    while (x >= -8) : (x -= 1) {
        print("@mod({}, 4): {}\n", .{ x, @mod(x, 4) });
    }
    // print("@mod(-4.1, 4): {}\n", .{@mod(-4.1, 4)});
    print("@rem(-5, 3): {}\n", .{@rem(-5, 3)});
    print("@rem(5, 3): {}\n", .{@rem(5, 3)});
}

test {
    try expect(@mod(-5, 3) == 1);
    try expect(@mod(5, 3) == 2);
    try expect(@rem(-5, 3) == -2);
    try expect(@rem(5, 3) == 2);
}
