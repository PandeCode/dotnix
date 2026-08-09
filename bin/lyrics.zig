//usr/bin/env , zig run -O ReleaseFast -freference-trace=10 -j$(nproc) "$0" -- "$@" ; exit

//usr/bin/env , zig run -lc -freference-trace=10 -j$(nproc) "$0" -- "$@" ; exit

const std = @import("std");
const http = std.http;
const mem = std.mem;
const ArrayList = std.ArrayList;
const Io = std.Io;
const Allocator = mem.Allocator;
const print = std.debug.print;

const WS = "\n\t\r ";

// fn comptime_expand(comptime path: []const u8) []const u8 { }

const CACHE_DIR = "~/.cache/lyrics_zig";
var TRUE_CACHE_DIR: ?[]const u8 = null; // idgaf

/// not having this in the stdlib is kinda stupid
/// small impl, idk if i could be more efficient
fn urlEncode(gpa: Allocator, url: []const u8) ![]const u8 {
    const chars = .{
        .{ "%", "%25" },
        .{ " ", "%20" },
        .{ ":", "%3A" },
        .{ "/", "%2F" },
        .{ "?", "%3F" },
        .{ "#", "%23" },
        .{ "[", "%5B" },
        .{ "]", "%5D" },
        .{ "@", "%40" },
        .{ "!", "%21" },
        .{ "$", "%24" },
        .{ "&", "%26" },
        .{ "'", "%27" },
        .{ "(", "%28" },
        .{ ")", "%29" },
        .{ "*", "%2A" },
        .{ "+", "%2B" },
        .{ ",", "%2C" },
        .{ ";", "%3B" },
        .{ "=", "%3D" },
    };

    var expansions: usize = 0;
    inline for (chars) |t| {
        expansions += mem.count(u8, url, t[0]);
    }
    var start_output = try gpa.alloc(u8, url.len + (expansions * 2));
    var end = url.len;
    @memcpy(start_output[0..end], url);

    inline for (chars) |t| {
        const output = try mem.replaceOwned(u8, gpa, start_output[0..end], t[0], t[1]);
        end = output.len;
        @memcpy(start_output[0..end], output);
        gpa.free(output);
    }

    return start_output;
}

/// just ~ for now
fn expand(gpa: Allocator, env: std.process.Environ, path: []const u8) ![]const u8 {
    const HOME: []const u8 = try env.getAlloc(gpa, "HOME");
    defer gpa.free(HOME);
    const output = try gpa.alloc(u8, path.len - 1 + HOME.len);
    _ = mem.replace(u8, path, "~", HOME, output);
    return output;
}

fn fetchWithCache(gpa: Allocator, io: Io, client: *http.Client, url: []const u8) ![]const u8 {
    var hash: [std.crypto.hash.Sha1.digest_length]u8 = undefined;
    std.crypto.hash.Sha1.hash(url, &hash, .{});

    const cache_dir = try Io.Dir.openDirAbsolute(io, TRUE_CACHE_DIR.?, .{});
    return cache_dir.readFileAlloc(io, &hash, gpa, .unlimited) catch |e| {
        switch (e) {
            error.FileNotFound => {
                var body: Io.Writer.Allocating = .init(gpa);
                defer body.deinit();

                const fetch_res = try client.fetch(.{
                    .location = .{ .url = url },
                    .method = .GET,
                    .response_writer = &body.writer,
                });

                if (fetch_res.status != .ok) {
                    print("url: {s}", .{url});
                    return error.ReqFail;
                }

                const res_body = try body.toOwnedSlice();

                try cache_dir.writeFile(io, .{
                    .sub_path = &hash,
                    .data = res_body,
                });
                return res_body;
            },
            else => unreachable,
        }
    };
}

const Lyric = struct {
    id: i64,
    name: []const u8,
    trackName: []const u8,
    artistName: []const u8,
    albumName: []const u8,
    duration: f32,
    instrumental: bool,
    plainLyrics: ?[]const u8,
    syncedLyrics: ?[]const u8,
    lyricsfile: []const u8,
};

const LTStamp = struct { timestamp: i64, line: []const u8 };
const LType = union(enum) { sync: []const LTStamp, unsync: []const []const u8 };

fn lrclib(allocator: Allocator, io: Io, client: *http.Client, info: []const u8) !?LType {
    // lol i love allocators
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const gpa = arena.allocator();

    const url = try std.fmt.allocPrint(
        gpa,
        "https://lrclib.net/api/search?q={s}",
        .{
            try urlEncode(gpa, info),
        },
    );

    const raw = try fetchWithCache(gpa, io, client, url);

    const json = try std.json.parseFromSlice([]Lyric, gpa, raw, .{});

    if (json.value.len == 0) return null;

    if (json.value[0].syncedLyrics) |lyrics| {
        var lyrics_list: ArrayList(LTStamp) = try .initCapacity(gpa, mem.count(u8, lyrics, "\n"));
        var iter = mem.splitScalar(u8, lyrics, '\n');

        while (iter.next()) |lyric| {
            // '[00:23.00] begin'
            // 0123456789AB
            const min = try std.fmt.parseFloat(f32, lyric[1..3]);
            const sec = try std.fmt.parseFloat(f32, lyric[4..9]);

            // we need microsecs since playerctl returns that
            const ms: i64 = @intFromFloat(sec * std.time.us_per_s + min * std.time.us_per_min);
            const _line = mem.trim(u8, lyric[11..], WS);

            const line = try allocator.alloc(u8, _line.len);
            @memcpy(line, _line);

            try lyrics_list.append(allocator, .{ .line = line, .timestamp = ms });
        }

        return .{ .sync = try lyrics_list.toOwnedSlice(allocator) };
    }
    if (json.value[0].plainLyrics) |lyrics| {
        var lyrics_list: ArrayList([]const u8) = try .initCapacity(gpa, mem.count(u8, lyrics, "\n"));
        var iter = mem.splitScalar(u8, lyrics, '\n');

        while (iter.next()) |lyric| {
            const _line = mem.trim(u8, lyric, WS);
            const line = try allocator.alloc(u8, _line.len);
            @memcpy(line, _line);
            try lyrics_list.append(allocator, line);
        }

        return .{ .unsync = try lyrics_list.toOwnedSlice(allocator) };
    }
    return null;
}

pub fn main(init: std.process.Init) !void {
    const gpa = init.arena.allocator();
    const io = init.io;
    const env = init.minimal.environ;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    var client: http.Client = .{ .allocator = gpa, .io = io };
    defer client.deinit();

    const cache_dir = try expand(gpa, env, CACHE_DIR);
    TRUE_CACHE_DIR = cache_dir;
    Io.Dir.createDirAbsolute(io, cache_dir, .default_dir) catch {};

    const playerctl = try std.process.run(gpa, io, .{ .argv = &.{
        "playerctl",
        "--player=spotify,mpv,firefox,chromium",
        "metadata",
        "--format",
        \\{{title}}
        \\{{artist}}
        \\{{position}}
    } });
    defer gpa.free(playerctl.stderr);
    defer gpa.free(playerctl.stdout);

    if (playerctl.term != .exited) return error.Playerctl;

    var playerctl_stdout = mem.tokenizeScalar(u8, mem.trim(u8, playerctl.stdout, WS), '\n');

    var title: ?[]const u8 = null;
    var artist: ?[]const u8 = null;
    var position: ?[]const u8 = null;

    {
        var i: u8 = 0;
        while (playerctl_stdout.next()) |md| : (i += 1) {
            switch (i) {
                0 => title = md,
                1 => artist = md,
                2 => position = md,
                else => {},
            }
        }
    }

    const lyrics = try lrclib(gpa, io, &client, try std.fmt.allocPrint(gpa, "{s} {s}", .{ title.?, artist.? }));
    if (lyrics) |lyric| {
        switch (lyric) {
            .sync => |sync| {
                const pos = try std.fmt.parseInt(i64, position.?, 10);

                var idx: usize = 0;
                for (sync, 0..) |s, i| {
                    if (pos < s.timestamp) {
                        idx = i;
                        break;
                    }
                }

                try stdout.print("{s}\n", .{sync[if (idx != 0) idx - 1 else 0].line});
            },
            .unsync => |unsync| {
                _ = unsync;
            },
        }
    }

    try stdout.flush();
}

// Future ref

// i only know how to get the url of the current browser for firefox
const yt_lyrics_start =
    \\from youtube_transcript_api import YouTubeTranscriptApi
    \\from youtube_transcript_api.formatters import TextFormatter
    \\
    \\def convert_to_timestamp_format(seconds):
    \\"""Convert seconds to [MM:SS.MS] format"""
    \\minutes = seconds // 60
    \\seconds_remainder = seconds % 60
    \\# Format with exactly 2 decimal places for milliseconds
    \\return f"[{minutes:02d}:{seconds_remainder:05.2f}]"
    \\
    \\def convert_json_to_timestamp_format(json_str):
    \\formatted_lines = []
    \\for entry in json_str:
    \\   timestamp = convert_to_timestamp_format(int(entry['start']))
    \\   formatted_lines.append(f"{timestamp} {entry['text']}")
    \\   return '\n'.join(formatted_lines)
    \\   t = YouTubeTranscriptApi.get_transcript(
;

// have a quoted id here
// \\    '$id'

const yt_lyrics_end =
    \\      )
    \\   print(convert_json_to_timestamp_format(t), end='\n')
;
