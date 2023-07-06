// https://ziggit.dev/t/how-to-apply-custom-formatting-to-slices/1066/2
const std = @import("std");

fn getReturnType(comptime function: anytype) type {
    return switch (@typeInfo(@TypeOf(function))) {
        .Fn => |x| x.return_type.?,
        else => {
            @compileError("invalid type");
        },
    };
}

fn map(array: anytype, function: anytype, out: []getReturnType(function)) []const getReturnType(function) {
    const info = @typeInfo(@TypeOf(function));

    var length: usize = 0;
    for (array, 0..) |item, i| {
        if (info == .Fn) {
            out[i] = function(item);
            length += 1;
        } else {
            @compileError("invalid type");
        }
    }
    return out[0..length];
}

pub fn main() !void {
    // Works: format a single number.
    const size: u64 = 100500;
    std.debug.print("{}\n", .{std.fmt.fmtIntSizeBin(size)});

    var out: [32]getReturnType(std.fmt.fmtIntSizeBin) = undefined;
    // Does not work :-(
    const sizes: []const u64 = &.{ 100500, 1234567 };
    std.debug.print("{any}\n", .{map(sizes, std.fmt.fmtIntSizeBin, &out)});
}
