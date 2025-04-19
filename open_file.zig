//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://www.reddit.com/r/Zig/comments/107wh7a/running_a_zig_file_like_a_script/

// [Zig Language | Thoughts After 2 Years | codingjerk](https://youtu.be/TCcPqhRaJqc)
const std = @import("std");
pub fn main() !void {
    const file = std.fs.cwd().openFile("password.txt", .{}) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("File not found!\n", .{});
            std.process.exit(1);
        },
        else => {
            std.debug.print("Something else happened\n", .{});
            std.process.exit(2);
        },
    };

    defer file.close();
    const buffer = std.heap.page_allocator.alloc(u8, 1024) catch @panic("Out of memory");
    defer std.heap.page_allocator.free(buffer);
    const read_bytes = try file.read(buffer);
    if (std.mem.eql(u8, buffer[0 .. read_bytes - 1], "very_secret")) {
        std.debug.print("Access granted\n", .{});
    } else {
        std.debug.print("Wrong secret: {s}: {x}\n", .{ buffer[0 .. read_bytes - 1], buffer[0 .. read_bytes - 1] });
        std.process.exit(1);
    }

    const stdout_writer = std.io.getStdOut().writer();
    var buffered_stdout = std.io.bufferedWriter(stdout_writer);
    defer buffered_stdout.flush() catch {};
    try buffered_stdout.writer().writeAll("INFO: user logged in\n");
}
