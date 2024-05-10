// https://youtu.be/E-MPhgtC_2s
const std = @import("std");

pub fn main() !void {
    std.debug.print("Hello, world!\n", .{});
    var big_list = std.ArrayList(u8).init(std.heap.page_allocator);
    try big_list.writer().print("Hello item\n", .{});
    defer big_list.deinit();
    std.debug.print("{s}\n", .{big_list.items});

    for (1..2) |item| {
        std.debug.print("{}\n", .{item});
    }
}
