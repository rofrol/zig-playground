const std = @import("std");
pub fn main() !void {
    std.debug.print("\n", .{});
    // wrong:
    // var buffer = [_]u8{0};
    const buffer_size = 20;
    var buffer: [buffer_size]u8 = undefined;
    const result_from_convert = convert(&buffer, 105);

    // std.debut.print not run when convert is called in TypeOf
    //std.debug.print("\nconvert: {any}\n", .{@TypeOf(convert(&buffer, 105))});

    // []const u8
    std.debug.print("@TypeOf(result_from_convert): {any}\n", .{@TypeOf(result_from_convert)});
}

pub fn convert(buffer: []u8, comptime n: u32) []const u8 {
    const pling = if (n % 3 == 0) "Pling" else "";
    const plang = if (n % 5 == 0) "Plang" else "";
    const plong = if (n % 7 == 0) "Plong" else "";
    const result = pling ++ plang ++ plong;
    // *const [15:0]u8
    std.debug.print("@TypeOf(result): {any}\n", .{@TypeOf(result)});
    return if (result.len > 0) result else std.fmt.bufPrint(buffer, "{}", .{n}) catch unreachable;
}
