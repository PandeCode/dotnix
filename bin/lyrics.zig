//usr/bin/env , zig run -freference-trace=10 -j$(nproc) "$0" -- "$@" ; exit

//usr/bin/env , zig run -freference-trace=10 -j$(nproc) "$0" -- "$@" ; exit

//usr/bin/env , zig run -lc -freference-trace=10 -j$(nproc) "$0" -- "$@" ; exit

const std = @import("std");

const http = std.http;
const mem = std.mem;
const log = std.log;
const ArrayList = std.ArrayList;
const Io = std.Io;
const Allocator = mem.Allocator;
const print = std.debug.print;

const WS = "\n\t\r ";

test "hello" {
    const E = union(enum) { a: u8, b: u9 };

    const e: E = .{ .a = 512 };
    const j: E = .{ .b = 9 };
    _ = e;
    _ = j;
}

const CACHE_DIR = "~/.cache/lyrics_zig";

fn sanitize(gpa: Allocator, str: []const u8) ![]const u8 {
    var ret = try gpa.alloc(u8, str.len);
    for (str, 0..) |c, i| {
        if (std.ascii.isAlphanumeric(c)) {
            ret[i] = c;
        } else {
            ret[i] = '_';
        }
    }
    return ret;
}

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

fn fetchWithCache(allocator: Allocator, io: Io, client: *http.Client, uri: std.Uri, cache_dir: Io.Dir) ![]const u8 {
    var arena = std.heap.ArenaAllocator.init(allocator);
    const gpa = arena.allocator();

    const query = try uri.query.?.toRawMaybeAlloc(gpa);
    const nhash = std.hash.XxHash32.hash(0, query);
    const hash = try std.fmt.allocPrint(gpa, "{}", .{nhash});

    const sanitizedQuery = try sanitize(gpa, query);

    return cache_dir.readFileAlloc(io, hash, gpa, .unlimited) catch |e| {
        switch (e) {
            error.FileNotFound => {
                var body: Io.Writer.Allocating = .init(allocator);
                defer body.deinit();

                const fetch_res = try client.fetch(.{
                    .location = .{ .uri = uri },
                    .response_writer = &body.writer,
                });

                if (fetch_res.status != .ok)
                    return error.ReqFail;

                const res_body = try body.toOwnedSlice();

                try cache_dir.writeFile(io, .{
                    .sub_path = try std.mem.concat(gpa, u8, &.{ hash, sanitizedQuery }),
                    .data = res_body,
                });
                return res_body;
            },
            else => unreachable,
        }
    };
}

const Metadata = struct {
    title: []const u8,
    artist: []const u8,
    position: i64,
};

fn getPlayerMetadata(io: Io, gpa: Allocator) !Metadata {
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

    var title: ?[]u8 = null;
    var artist: ?[]u8 = null;
    var position: ?i64 = null;

    var i: u8 = 0;
    while (playerctl_stdout.next()) |md| : (i += 1) {
        switch (i) {
            0 => {
                title = try gpa.alloc(u8, md.len);
                @memcpy(title.?, md);
            },
            1 => {
                artist = try gpa.alloc(u8, md.len);
                @memcpy(artist.?, md);
            },
            2 => position = try std.fmt.parseInt(i64, md, 10),
            else => unreachable,
        }
    }

    return .{
        .title = title.?,
        .artist = artist.?,
        .position = position.?,
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

fn lrclib(allocator: Allocator, io: Io, client: *http.Client, query: []const u8, cache_dir: Io.Dir) !?LType {
    // lol i love allocators
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const gpa = arena.allocator();

    const url = try std.fmt.allocPrint(
        gpa,
        "https://lrclib.net/api/search?q={s}",
        .{
            try urlEncode(gpa, query),
        },
    );

    const uri = try std.Uri.parse(url);

    const raw = try fetchWithCache(gpa, io, client, uri, cache_dir);
    const json = try std.json.parseFromSlice([]Lyric, gpa, raw, .{});

    if (json.value.len == 0) return null;

    if (json.value[0].syncedLyrics) |lyrics| {
        var lyrics_list: ArrayList(LTStamp) = try .initCapacity(gpa, mem.count(u8, lyrics, "\n"));
        var iter = mem.splitScalar(u8, lyrics, '\n');

        while (iter.next()) |lyric| {
            // '[00:23.00] begin'
            // '0123456789AB'
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
    const mgpa = init.arena.allocator();
    const io = init.io;
    const env = init.minimal.environ;

    var stdout_writer = Io.File.stdout().writer(init.io, &.{});
    const stdout = &stdout_writer.interface;

    var client: http.Client = .{ .allocator = mgpa, .io = io };
    defer client.deinit();

    const cache_dir_path = try expand(mgpa, env, CACHE_DIR);
    defer mgpa.free(cache_dir_path);

    Io.Dir.createDirAbsolute(io, cache_dir_path, .default_dir) catch |e| {
        switch (e) {
            error.PathAlreadyExists => {},
            else => unreachable,
        }
    };
    const cache_dir = try Io.Dir.openDirAbsolute(io, cache_dir_path, .{});

    var loopArena = std.heap.ArenaAllocator.init(mgpa);
    defer loopArena.deinit();
    const gpa = loopArena.allocator();

    while (loopArena.reset(.retain_capacity)) {
        try init.io.sleep(.fromSeconds(1), .real);
        const metadata = getPlayerMetadata(io, gpa) catch continue;
        const title = metadata.title;
        const artist = metadata.artist;
        const position = metadata.position;

        const lyrics = try lrclib(gpa, io, &client, try std.fmt.allocPrint(gpa, "{s} {s}", .{ title, artist }), cache_dir);
        if (lyrics) |lyric| {
            switch (lyric) {
                .sync => |sync| {
                    var idx: usize = 0;
                    for (sync, 0..) |s, i| {
                        if (position < s.timestamp) {
                            idx = i;
                            break;
                        }
                    }

                    try stdout.print("{s}\n", .{sync[if (idx != 0) idx else 0].line});
                },
                .unsync => |unsync| {
                    _ = unsync;
                },
            }
        }

        try stdout.flush();
    }
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
