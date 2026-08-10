//usr/bin/env , zig run -freference-trace=10 -j$(nproc) "$0" -- "$@" ; exit

const std = @import("std");

fn escape(gpa: std.mem.Allocator, url: []const u8) ![]const u8 {
    // "\n"Newline
    // "\r"Carriage Return
    // "\t"Tab
    // "\\"Backslash
    // "\'"Single Quote
    // "\""Double Quote
    // "\xNN"hexadecimal 8-bit byte value (2 digits)
    // "\u{NNNNNN}"hexadecimal Unicode scalar value UTF-8 encoded (1 or more digits)
    // }

    const chars = .{
        .{ "\\", "\\\\" },
        .{ "\t", "\\t" },
        .{ "\n", "\\n" },
        .{ "\r", "\\r" },
        .{ "\"", "\\\"" },
    };

    var expansions: usize = 0;
    inline for (chars) |t| {
        expansions += (t[1].len - t[0].len) * std.mem.count(u8, url, t[0]);
    }
    var start_output = try gpa.alloc(u8, url.len + expansions);
    var end = url.len;
    @memcpy(start_output[0..end], url);

    inline for (chars) |t| {
        const output = try std.mem.replaceOwned(u8, gpa, start_output[0..end], t[0], t[1]);
        end = output.len;
        @memcpy(start_output[0..end], output);
        gpa.free(output);
    }

    return start_output;
}

pub fn main(init: std.process.Init) !void {
    const gpa = init.arena.allocator();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    const envMap = try init.minimal.environ.createMap(gpa);
    var envIter = envMap.iterator();

    while (envIter.next()) |env| {
        const key = env.key_ptr.*;
        const val = try escape(gpa, env.value_ptr.*);
        if (std.zig.isValidId(key)) {
            try stdout.print("pub const {s} = \"{s}\";\n", .{ key, val });
        } else try stdout.print("pub const @\"{s}\" = \"{s}\";\n", .{ key, val });
    }

    try stdout.flush();
}
