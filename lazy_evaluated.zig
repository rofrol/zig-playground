const std = @import("std");

// > Every object (being constant or variable) that you declare in Zig must be used in some way.
//
// This is true for eagerly evaluated code (function bodies) and false for lazily evaluated code (struct definitions). That latter thing already trips people up because you can have full-on compiler errors defined somewhere and never know because they're never used (depending on your build mode, there will be some root artifacts -- tests for test builds, main for executable builds, export functions for library builds, transitively visible public members for modules -- and only code transitively referenced by those artifacts is compiled). Explicitly stating the opposite is going to confuse some beginners.
// https://news.ycombinator.com/item?id=41903685

pub fn main() !void {
    // defer will not be called if we use std.process.exit
    // https://www.reddit.com/r/Zig/comments/1eea56x/comment/lfephma/
    // to return specific number, we have to change return type of main to !u8
    // https://news.ycombinator.com/item?id=41918325
    defer std.debug.print("deref\n", .{});
    // std.process.exit(0);
}
