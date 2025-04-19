//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://www.reddit.com/r/Zig/comments/107wh7a/running_a_zig_file_like_a_script/

// https://ziggit.dev/t/zig-0-14-0-released/8890/17
// https://chatgpt.com/c/68032bf7-4a80-800b-956d-72315183c7d5
const std = @import("std");
const eql = std.mem.eql;
const test_allocator = std.testing.allocator;
const mem = std.mem;
const Allocator = mem.Allocator;

test "arraylist" {
    const MyList = ManagedArrayList(u8);
    var list = MyList.init(test_allocator);
    defer list.deinit();
    try list.ensureUnusedCapacity(10);
    list.appendAssumeCapacity('H');
    list.appendAssumeCapacity('e');
    list.appendAssumeCapacity('l');
    list.appendAssumeCapacity('l');
    list.appendAssumeCapacity('o');
    list.appendSliceAssumeCapacity(" World!");
    //
    try std.testing.expect(eql(u8, list.list.items, "Hello World!"));
}

pub fn ManagedArrayList(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        list: std.ArrayListUnmanaged(T),
        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .list = .empty,
            };
        }

        pub fn deinit(self: *Self) void {
            // exactly the old behavior: free all memory on drop
            self.list.deinit(self.allocator);
        }

        pub fn append(self: *Self, value: T) !void {
            // forward to the unmanaged append, passing our allocator
            try self.list.append(self.allocator, value);
        }

        pub fn ensureUnusedCapacity(self: *Self, n: usize) !void {
            try self.list.ensureUnusedCapacity(self.allocator, n);
        }

        pub fn appendAssumeCapacity(self: *Self, value: T) void {
            self.list.appendAssumeCapacity(value);
        }

        /// Append the slice of items to the list.
        /// Never invalidates element pointers.
        /// Asserts that the list can hold the additional items.
        pub fn appendSliceAssumeCapacity(self: *Self, items: []const T) void {
            const old_len = self.list.items.len;
            const new_len = old_len + items.len;
            std.debug.assert(new_len <= self.list.capacity);
            self.list.items.len = new_len;
            @memcpy(self.list.items[old_len..][0..items.len], items);
        }
    };
}
