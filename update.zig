//usr/bin/env , zig run "$0" -- "$@"; exit

const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const Allocator = std.mem.Allocator;
const Io = std.Io;
const ArrayList = std.ArrayList;

const print = std.debug.print;

/// This is always gonna be heap allocated
const String = ArrayList(u8);

// we need to look at

// zig fmt: off
const flakes = .{
     .{ .path = "~/dev/nixutils",  .url = null, },
     .{ .path = "~/dev/nixbuilds", .url = null, },
     .{ .path = "~/dotnix",        .url = null, },
     .{ .path = "~/dotnix-private", .url = "dotnix-private" },
     .{ .path = "~/hermes",        .url = null, },
     .{ .path = "~/libys",         .url = null, },
};
// zig fmt: on

/// just ~ for now
fn expand(gpa: Allocator, env: std.process.Environ, path: []const u8) ![]const u8 {
    const HOME: []const u8 = try env.getAlloc(gpa, "HOME");
    defer gpa.free(HOME);
    const output = try gpa.alloc(u8, path.len - 1 + HOME.len);
    _ = mem.replace(u8, path, "~", HOME, output);
    return output;
}

fn nixEval(gpa: Allocator, io: std.Io, expr: []const u8) ![]const u8 {
    const run_result = try std.process.run(gpa, io, .{ .argv = &.{
        "nix",
        "eval",
        "--impure",
        "--expr",
        expr,
    } });
    defer gpa.free(run_result.stderr);
    if (run_result.term != .exited) return error.Failed;
    return run_result.stdout;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;

    inline for (flakes) |flake| {
        if (@TypeOf(flake.url) != @TypeOf(null)) {
            std.debug.print("{s}", .{flake.url});
        }

        const dirName = try expand(gpa, init.minimal.environ, flake.path);
        defer gpa.free(dirName);

        const flake_file = try mem.concat(gpa, u8, &.{ dirName, "/flake.nix" });
        defer gpa.free(flake_file);

        const expr = try fmt.allocPrint(gpa, "(import {s}).inputs", .{flake_file});
        defer gpa.free(expr);

        const res = try nixEval(gpa, io, expr);
        defer gpa.free(res);

        print("{s}\n", .{res});
    }
}
