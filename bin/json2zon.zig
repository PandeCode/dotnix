//usr/bin/env , zig run -freference-trace=10 -j$(nproc) "$0" -- "$@" ; exit

const std = @import("std");
const zon = std.zon;
const json = std.json;

const Io = std.Io;

const Options = struct {
    dotEnums: bool = false,
};

fn json2Zon(writer: *Io.Writer, val: std.json.Value, opts: Options) !void {
    switch (val) {
        .null => try writer.writeAll("null"),
        .bool => |v| try writer.print("{}", .{v}),
        .integer => |v| try writer.print("{}", .{v}),
        .float => |v| try writer.print("{}", .{v}),
        .string, .number_string => |s| {
            if (opts.dotEnums and s.len > 0 and s[0] == '.') {
                try std.zig.stringEscape(s, writer);
            } else {
                try writer.writeByte('"');
                try std.zig.stringEscape(s, writer);
                try writer.writeByte('"');
            }
        },
        .array => |arr| {
            try writer.writeAll(".{");
            for (arr.items) |i| {
                try json2Zon(writer, i, opts);
                try writer.writeByte(',');
            }
            try writer.writeByte('}');
        },
        .object => |obj| {
            try writer.writeAll(".{");
            var iter = obj.iterator();
            while (iter.next()) |i| {
                try writer.writeByte('.');

                if (std.zig.isValidId(i.key_ptr.*)) {
                    try writer.writeAll(i.key_ptr.*);
                } else {
                    try writer.writeAll("@\"");
                    try std.zig.stringEscape(i.key_ptr.*, writer);
                    try writer.writeByte('"');
                }

                try writer.writeAll(" = ");
                try json2Zon(writer, i.value_ptr.*, opts);
                try writer.writeByte(',');
            }
            try writer.writeByte('}');
        },
    }
}

pub fn main(init: std.process.Init) !void {
    const gpa = init.arena.allocator();

    const dot = blk: {
        var iter = init.minimal.args.iterate();
        while (iter.next()) |i| {
            if (std.mem.eql(u8, i, "--dot")) break :blk true;
        }
        break :blk false;
    };

    var buffer: [1024]u8 = undefined;
    var stdin_reader = Io.File.stdin().reader(init.io, &buffer);
    var stdin_writer = Io.Writer.Allocating.init(gpa);
    defer stdin_writer.deinit();
    _ = stdin_reader.interface.streamDelimiter(&stdin_writer.writer, 0) catch |err|
        if (err != error.EndOfStream) return err;

    const j = try json.parseFromSlice(json.Value, gpa, try stdin_writer.toOwnedSlice(), .{});

    var stdout_writer = Io.File.stdout().writer(init.io, &.{});
    const stdout = &stdout_writer.interface;

    try json2Zon(stdout, j.value, .{ .dotEnums = dot });
    try stdout.flush();
}
