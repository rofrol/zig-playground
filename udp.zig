//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://www.reddit.com/r/Zig/comments/107wh7a/running_a_zig_file_like_a_script/

// run python udp.py to test
// for receiver using netcat: nc -ul 8080
const std = @import("std");
const os = std.os;
const log = std.log;
const bufsz = 1024;
pub fn main() !void {
    var sock = try os.socket(os.AF.INET6, os.SOCK.DGRAM, 0);

    const port = 8080;
    const addr = try std.net.Address.parseIp6("::", port);

    try os.bind(sock, &addr.any, addr.getOsSockLen());
    defer os.close(sock);

    log.info("listening on port {d}", .{port});

    var ara = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = ara.deinit();

    var buf: [bufsz]u8 = undefined;
    var caddr: os.sockaddr = undefined;
    var caddr_len: os.socklen_t = undefined;

    while (true) {
        const size = try os.recvfrom(sock, &buf, bufsz, &caddr, &caddr_len);
        std.debug.print("{} {s}\n", .{ caddr, buf[0..size] });
    }
}
