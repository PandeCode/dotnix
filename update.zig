//usr/bin/env , zig run "$0" -- "$@"; exit

const std = @import("std");

// we need to look at

const flakes = .{
    .nixutils = .{ .path = "~/nixutils ", .url = .assume },
    .nixbuilds = .{ .path = "~/nixbuilds ", .url = .assume },
    .dotnix = .{ .path = "~/dotnix ", .url = .assume },
    .dotnix_private = .{ .path = "~/dotnix-private", .url = "dotnix-private" },
    .hermes = .{ .path = "~/hermes ", .url = .assume },
    .libys = .{ .path = "~/libys ", .url = .assume },
};

pub fn main(init: std.process.Init) void {
    _ = init;
}
