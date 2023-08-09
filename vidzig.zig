//usr/bin/env zig run --enable-cache "$0" -- "$@" | tail -n +2; exit;
// https://www.reddit.com/r/Zig/comments/107wh7a/running_a_zig_file_like_a_script/

// https://git.mzte.de/LordMZTE/vidzig/raw/branch/master/src/main.zig
const std = @import("std");
const assets = @import("assets");

const routes = @import("routes.zig");

const minify = @import("minify.zig");
const sendPlainResponseText = @import("status_response.zig").sendPlainResponseText;
const DownloadQueue = @import("DownloadQueue.zig");
const Config = @import("Config.zig");
const State = @import("State.zig");

test {
    std.testing.refAllDeclsRecursive(@This());
}

pub const std_options = struct {
    pub const log_level = .debug;
};

var running_server: ?*std.http.Server = null;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var arg_it = try std.process.argsWithAllocator(alloc);
    defer arg_it.deinit();

    const progname = blk: {
        break :blk try alloc.dupe(u8, arg_it.next() orelse break :blk null);
    };
    defer if (progname) |n| {
        alloc.free(n);
    };

    const config_path = arg_it.next();

    if (config_path == null) {
        std.log.err(
            \\Usage:
            \\  {s} <CONFIG_FILE>
        ,
            .{progname orelse "vidzig"},
        );
        return error.InvalidCli;
    }

    //const conf = try Config.parse(alloc, config_path.?);
    //defer std.json.parseFree(Config, conf, .{ .allocator = alloc });

    const conf = try Config.parse(alloc, config_path.?);
    defer conf.deinit(alloc);

    std.log.info("creating data dir @ {s}", .{conf.data_dir});
    const vids_path = try std.fs.path.join(alloc, &.{ conf.data_dir, "vids" });
    defer alloc.free(vids_path);

    try std.fs.cwd().makePath(vids_path);

    var server = std.http.Server.init(alloc, .{});
    defer server.deinit();

    try server.listen(conf.bind);
    std.log.info("listening on {}", .{conf.bind});

    var state = State{
        .downloads = undefined,
        .vids_dir = vids_path,
        .conf = conf,
    };

    const downloads = try DownloadQueue.spawn(alloc, &state);
    defer alloc.destroy(downloads);
    state.downloads = downloads;

    running_server = &server;
    defer running_server = null;

    try std.os.sigaction(std.os.SIG.INT, &.{
        .handler = .{ .handler = &onSigint },
        .mask = std.os.empty_sigset,
        .flags = (std.os.SA.SIGINFO | std.os.SA.RESTART),
    }, null);

    while (true) {
        var res = server.accept(.{ .allocator = alloc }) catch |e| {
            // interrupted by signal
            if (e == error.SocketNotListening and running_server == null)
                break;

            return e;
        };
        errdefer res.deinit();

        const thread = try std.Thread.spawn(.{}, handleRequest, .{ &state, res });
        try thread.setName("HTTP Worker");
        thread.detach();
    }
}

fn handleRequest(state: *State, res: std.http.Server.Response) void {
    tryHandleRequest(state, res) catch |e| {
        std.log.warn("handling request: {}", .{e});
    };
}

fn tryHandleRequest(state: *State, res_: std.http.Server.Response) !void {
    var res = res_;
    defer res.deinit();

    while (true) {
        try res.wait();

        const path = res.request.target;

        std.log.info("{s} {s} from {}", .{
            @tagName(res.request.method),
            path,
            res.address,
        });

        if (std.mem.eql(u8, path, "/") or std.mem.eql(u8, path, "/index.html")) {
            try routes.indexRoute(state, &res);
        } else if (std.mem.eql(u8, path, "/index.json")) {
            try routes.indexJsonRoute(state, &res);
        } else if (std.mem.eql(u8, path, "/set_paused")) {
            try routes.setPausedRoute(state, &res);
        } else if (std.mem.eql(u8, path, "/static/index.js")) {
            try routes.static(&res, assets.@"index.js", "application/javascript");
        } else if (std.mem.eql(u8, path, "/static/index.css")) {
            try routes.static(&res, assets.@"index.css", "text/css");
        } else if (std.mem.eql(u8, path, "/static/vidzig.png") or
            std.mem.eql(u8, path, "/favicon.ico"))
        {
            try routes.static(&res, assets.@"vidzig.png", "image/png");
        } else if (std.mem.eql(u8, path, "/static/vidzig.svg")) {
            try routes.static(
                &res,
                comptime minify.minifyHTML(assets.@"vidzig.svg"),
                "image/svg+xml",
            );
        } else if (std.mem.startsWith(u8, path, "/vids/")) {
            try routes.vidsRoute(state, &res);
        } else {
            try sendPlainResponseText(&res, .not_found);
        }

        if (res.reset() == .closing)
            break;
    }
}

fn onSigint(_: c_int) callconv(.C) void {
    std.log.warn("caught signal", .{});
    if (running_server) |srv| {
        running_server = null;
        if (srv.socket.sockfd) |fd| {
            std.os.shutdown(fd, .both) catch |e| {
                std.log.err("trying to shut down server: {}", .{e});
                std.os.exit(1);
            };
        }
    }
}
