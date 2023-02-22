//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://www.reddit.com/r/Zig/comments/107wh7a/running_a_zig_file_like_a_script/

const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const val = 1;
    const switched = blk: {
      switch(val) {
        0 => {
          break :blk "zero";
        },
        1 => {
          break :blk "one";
        },
        else => {
          break :blk "other";
        },
      }
    };

    print("{s}\n", .{switched});
}
// https://discord.com/channels/605571803288698900/1077301291736375397
