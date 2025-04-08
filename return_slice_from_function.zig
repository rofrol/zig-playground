const std = @import("std");

/// Takes a slice as a parameter and fills it with a message.
fn zigBits(slice: []u8) usize {
    // Create an array literal.
    var message = [_]u8{ 'z', 'i', 'g', 'b', 'i', 't', 's' };

    // Print the array as string.
    std.log.debug("{s}", .{message});

    // Update the slice.
    std.mem.copyForwards(u8, slice, &message);
    return message.len;
}

pub fn main() void {
    // Define the message buffer.
    var message: [9]u8 = undefined;

    // Get the message.
    const len = zigBits(&message);

    // Print the message.
    std.log.debug("{s}", .{message[0..len]});
}
