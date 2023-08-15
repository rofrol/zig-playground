const std = @import("std");
pub fn main() !void {
    std.debug.print("\n", .{});
    const file = try std.fs.cwd().createFile("junk_file.txt", .{ .read = true });
    defer file.close();
    try std.fs.rename(std.fs.cwd(), "junk_file.txt", std.fs.cwd(), "new_file.txt");
    std.debug.print("file renamed\n", .{});
}
