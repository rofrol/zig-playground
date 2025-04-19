//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://www.reddit.com/r/Zig/comments/107wh7a/running_a_zig_file_like_a_script/

// https://ziggit.dev/t/zig-0-14-0-released/8890/17
const std = @import("std");
const eql = std.mem.eql;
const test_allocator = std.testing.allocator;
const mem = std.mem;
const Allocator = mem.Allocator;

test "arraylist" {
    const MyList = ManagedArrayList(i32);
    var list = MyList.init(test_allocator);
    defer list.deinit();
    try list.append(10);
    try list.ensureUnusedCapacity(1);
    list.appendAssumeCapacity(20);
    std.debug.print("items = {any}\n", .{list.items()});

    // appendSliceAssumeCapacity

    // var list = ArrayList(u8).init(test_allocator);
    // defer list.deinit();
    // try list.append('H');
    // try list.append('e');
    // try list.append('l');
    // try list.append('l');
    // try list.append('o');
    // try list.appendSlice(" World!");
    //
    // try std.testing.expect(eql(u8, try list.items, "Hello World!"));
}

pub fn ArrayList(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        _underlying_array_list: std.ArrayListUnmanaged(T),

        pub fn init(allocator: std.mem.Allocator) ArrayList(T) {
            return Self{
                .allocator = allocator,
                ._underlying_array_list = .{},
            };
        }

        pub fn deinit(self: *Self) void {
            self._underlying_array_list.deinit(self.allocator);
        }

        pub fn append(self: *Self, item: T) !void {
            try self._underlying_array_list.append(self.allocator, item);
        }

        pub fn toOwnedSlice(self: *Self) !std.ArrayListUnmanaged(T).Slice {
            return self._underlying_array_list.toOwnedSlice(self.allocator);
        }

        pub fn appendSlice(self: *Self, items: []const T) Allocator.Error!void {
            try self.ensureUnusedCapacity(items.len);
            self.appendSliceAssumeCapacity(items);
        }
    };
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

        pub fn items(self: *Self) []T {
            return self.list.items;
        }
    };
}
