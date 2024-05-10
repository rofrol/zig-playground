//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://github.com/ziglang/zig/issues/19909
const std = @import("std");

pub const Selection = struct {
    value: u8,
};
pub const CursorPosition = struct {
    pos: Selection,
    opt_pos: ?Selection = null,
};

test "miscompilation" {
    var self = CursorPosition{
        .pos = .{ .value = 3 },
    };
    const start_pos = self.opt_pos orelse self.pos;

    try std.testing.expectEqual(@as(u8, 3), start_pos.value); // OK
    self.pos.value = 10;
    try std.testing.expectEqual(@as(u8, 3), start_pos.value); // Error
}
