//usr/bin/env , zig run -freference-trace=10 -j$(nproc) "$0" -- "$@" ; exit

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var stdout_writer = std.Io.File.stdout().writer(init.io, &.{});
    const stdout = &stdout_writer.interface;

    var envIter = init.environ_map.iterator();

    while (envIter.next()) |env| {
        try stdout.print("pub const {f} = \"", .{std.zig.FormatId{ .bytes = env.key_ptr.*, .flags = .{} }});
        try std.zig.stringEscape(env.value_ptr.*, stdout);
        try stdout.writeAll("\";\n");
    }

    try stdout.flush();
}
