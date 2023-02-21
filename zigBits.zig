//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://www.reddit.com/r/Zig/comments/107wh7a/running_a_zig_file_like_a_script/
const std = @import("std");

fn zigBits(slice: []u8) usize {
    // Create an array literal.
    var message = [_]u8{ 'z', 'i', 'g', 'b', 'i', 't', 's' };

    // Print the array as string.
    std.log.debug("{s}", .{message});

    // Update the slice.
    std.mem.copy(u8, slice, &message);
    return message.len;
}

pub fn main() void {
    // Define the message buffer.
    var message: [9]u8 = undefined;

    // Get the message.
    _ = zigBits(&message);

    // Print the message.
    std.log.debug("{s}", .{message});
}
