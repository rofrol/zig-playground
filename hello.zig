//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://www.reddit.com/r/Zig/comments/107wh7a/running_a_zig_file_like_a_script/
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

const count: u32 = 1;
const result: []const u32 = blk: {
  var res: []const u32 = &.{};
  res = res ++ &[_]u32{count};
  break :blk res;
};  

pub fn main() void {
  print("result: {d}\n", .{result}); // 3
  var int: u2 = 0;
  int -%= 1;
  print("{}\n", .{int}); // 3

  var some_integers: [3]i32 = undefined;

  for (some_integers) |*item, i| {
     //item.* = i; // error: expected type 'i32', found 'usize'
     item.* = @intCast(i32, i);
  }

  print("{}\n", .{some_integers[2]});

  //const value: u32 = while (true) {
  //  if (false) break;
  //  break false; // returns `3` from the while loop
  //} else return;

  //print("{}\n", .{value});
}

test "error union" {
    const AllocationError = error{OutOfMemory};
    const maybe_error: AllocationError!u16 = 10;
    //const no_error = maybe_error catch 0;
    const no_error = maybe_error catch return;

    try expect(@TypeOf(no_error) == u16);
    try expect(no_error == 10);
}

//test "for else" {
//    // For allows an else attached to it, the same as a while loop.
//    var items = [_]anyerror!i32{ 3, 4, error.NoneAvailable, 5 };
//
//    // For loops can also be used as expressions.
//    var sum: i32 = 0;
//    comptime var i = 0;
//    while (items[i]) |value| {
//        sum += value;
//        i += 1;
//    } else |err| {
//        std.log.warn("error in items: {}\n", .{err});
//    }
//    try expect(sum == 7);
//}

test "switch statement" {
    var x: i8 = 10;
    switch (x) {
        -1...1 => {
            x = -x;
        },
        10, 100 => {
            //special considerations must be made
            //when dividing signed integers
            x = @divExact(x, 10);
        },
        else => {},
    }
    try expect(x == 1);
}
