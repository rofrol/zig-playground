// https://github.com/ziglang/zig/pull/25333
fn foo() *i32 {
    var x: i32 = 1234;
    return &x;
}

pub fn main() !void {
  _ = foo();
}
