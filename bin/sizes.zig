//usr/bin/env , zig run -freference-trace=10 -j$(nproc) "$0" -- "$@" ; exit

// sizes alignment and padding helper
// usually i depend on on ccls for this or just manually printf sizeof

const std = @import("std");
const mem = std.mem;
const Io = std.Io;

const Allocator = std.mem.Allocator;

pub fn main(init: std.process.Init) !void {
    _ = init;
}

const AlignmentInfo = struct {};

pub fn giveMeCStructInfo(cStruct: []const u8) AlignmentInfo {
    _ = cStruct;

    return .{};
}
