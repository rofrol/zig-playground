// https://x.com/AstraKernel/status/1763547847369355740
// If we're wrong and use @ptrCast to convert a pointer into a type incompatible with the underlying memory, we'll have serious runtime issues, with a crash being the best possible outcome. https://www.openmymind.net/Zig-Interfaces/
// https://www.openmymind.net/Zig-Tiptoeing-Around-ptrCast/
const std = @import("std");
const print = std.debug.print;
const Person = struct {
    name: []const u8,
};
const Student = struct {
    name: []const u8,
    id: u32,
};
pub fn main() void {
    var p = Person{
        .name = "Kernel",
    };
    const s: *Student = @ptrCast(&p);
    print("{d}\n", .{s.id});
    print("{s}\n", .{s.name});
}
