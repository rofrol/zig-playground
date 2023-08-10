// cancername https://discord.com/channels/605571803288698900/1139116271791779920/1139121337756024863
const std = @import("std");

pub fn main() !void {
    var it_d = try std.fs.cwd().openIterableDir(".", .{});
    defer it_d.close();
    {
        var it = it_d.iterateAssumeFirstIteration();
        while (try it.next()) |entry| {
            std.mem.doNotOptimizeAway(entry);
            std.debug.print("{s}\n", .{entry.name});
        }
    }
}
