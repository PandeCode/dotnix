//usr/bin/env , zig run -freference-trace=10 -j$(nproc) "$0" -- "$@" ; exit

// prints the lyric line playing now: synced lyrics from lrclib for songs,
// youtube captions (through python's youtube-transcript-api) for videos.
// -f, --follow keeps running and prints a line whenever it changes.
// PRINT_PLAYER=1 prints the player's name first.

const std = @import("std");

const Io = std.Io;
const mem = std.mem;
const Allocator = mem.Allocator;

const follow_interval: Io.Duration = .fromMilliseconds(500);
// std.http has no timeouts of its own, and a dropped connection would hang a bar
const fetch_timeout: Io.Duration = .fromSeconds(10);
const python_timeout: Io.Duration = .fromSeconds(30);

/// one timed line; us is microseconds, as playerctl reports positions
const Line = struct {
    us: i64,
    text: []const u8,
};

const Player = struct {
    /// the playerctl instance, e.g. spotify or firefox.instance_1_42
    name: []const u8,
    playing: bool,
    title: []const u8,
    artist: []const u8,
    album: []const u8,
    url: []const u8,
    position: i64,

    fn kind(p: Player) []const u8 {
        return p.name[0 .. mem.indexOfScalar(u8, p.name, '.') orelse p.name.len];
    }

    fn isSpotify(p: Player) bool {
        return mem.startsWith(u8, p.kind(), "spotify");
    }

    fn isFirefox(p: Player) bool {
        const k = p.kind();
        return mem.eql(u8, k, "firefox") or mem.eql(u8, k, "zen") or mem.eql(u8, k, "librewolf");
    }

    /// what the current song is, to know when to look lyrics up again
    fn key(p: Player, gpa: Allocator) ![]u8 {
        return std.fmt.allocPrint(gpa, "{s}\n{s}\n{s}\n{s}\n{s}", .{ p.kind(), p.title, p.artist, p.album, p.url });
    }

    fn fallback(p: Player, gpa: Allocator) ![]const u8 {
        if (p.artist.len == 0) return p.title;
        return std.fmt.allocPrint(gpa, "{s} - {s}", .{ p.title, p.artist });
    }
};

const Ctx = struct {
    io: Io,
    env: *const std.process.Environ.Map,
    client: *std.http.Client,
    cache: Io.Dir,
};

/// every player playerctl knows, one tab separated line each
fn players(ctx: Ctx, gpa: Allocator) ![]Player {
    const res = try std.process.run(gpa, ctx.io, .{ .argv = &.{
        "playerctl",
        "--all-players",
        "metadata",
        "--format",
        "{{playerInstance}}\t{{status}}\t{{title}}\t{{artist}}\t{{album}}\t{{position}}\t{{xesam:url}}",
    } });
    // exits 1 with "No players found"
    if (res.term != .exited or res.term.exited != 0) return &.{};

    var list: std.ArrayList(Player) = .empty;
    var lines = mem.tokenizeScalar(u8, res.stdout, '\n');
    while (lines.next()) |line| {
        var f = mem.splitScalar(u8, line, '\t');
        const name = f.next() orelse continue;
        const status = f.next() orelse continue;
        try list.append(gpa, .{
            .name = name,
            .playing = mem.eql(u8, status, "Playing"),
            .title = mem.trim(u8, f.next() orelse "", " "),
            .artist = mem.trim(u8, f.next() orelse "", " "),
            .album = mem.trim(u8, f.next() orelse "", " "),
            .position = std.fmt.parseInt(i64, f.next() orelse "", 10) catch 0,
            .url = f.next() orelse "",
        });
    }
    return list.items;
}

/// the first one playing, else the first one there is
fn pick(list: []Player) ?Player {
    for (list) |p| if (p.playing) return p;
    return if (list.len > 0) list[0] else null;
}

fn urlEncode(gpa: Allocator, s: []const u8) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    for (s) |c| {
        if (std.ascii.isAlphanumeric(c) or mem.indexOfScalar(u8, "-._~", c) != null) {
            try out.append(gpa, c);
        } else {
            try out.print(gpa, "%{X:0>2}", .{c});
        }
    }
    return out.toOwnedSlice(gpa);
}

/// the body of a GET, from the cache when it was fetched before
fn fetch(ctx: Ctx, gpa: Allocator, url: []const u8) ![]u8 {
    const name = try std.fmt.allocPrint(gpa, "{x:0>16}", .{std.hash.Wyhash.hash(0, url)});
    if (ctx.cache.readFileAlloc(ctx.io, name, gpa, .limited(16 << 20))) |body| {
        return body;
    } else |err| if (err != error.FileNotFound) return err;

    const Race = union(enum) {
        body: anyerror![]u8,
        timeout: Io.Cancelable!void,
    };
    var buf: [2]Race = undefined;
    var race: Io.Select(Race) = .init(ctx.io, &buf);
    defer while (race.cancel()) |_| {};
    try race.concurrent(.body, get, .{ ctx, gpa, url });
    try race.concurrent(.timeout, Io.sleep, .{ ctx.io, fetch_timeout, .awake });
    const body = switch (try race.await()) {
        .body => |b| try b,
        .timeout => return error.Timeout,
    };
    try ctx.cache.writeFile(ctx.io, .{ .sub_path = name, .data = body });
    return body;
}

fn get(ctx: Ctx, gpa: Allocator, url: []const u8) anyerror![]u8 {
    var body: Io.Writer.Allocating = .init(gpa);
    const res = try ctx.client.fetch(.{
        .location = .{ .url = url },
        .response_writer = &body.writer,
        .headers = .{ .user_agent = .{ .override = "lyrics.zig (github.com/PandeCode/dotnix)" } },
    });
    if (res.status != .ok) return error.HttpStatus;
    return body.written();
}

/// "mm:ss.xx", "mm:ss.xxx" or "mm:ss" in microseconds
fn parseStamp(s: []const u8) ?i64 {
    const colon = mem.indexOfScalar(u8, s, ':') orelse return null;
    const min = std.fmt.parseInt(i64, s[0..colon], 10) catch return null;
    const sec = std.fmt.parseFloat(f64, s[colon + 1 ..]) catch return null;
    if (min < 0 or sec < 0) return null;
    return min * std.time.us_per_min + @as(i64, @intFromFloat(@round(sec * std.time.us_per_s)));
}

/// an lrc file: "[00:12.34] text", with several stamps on one line allowed and [ar:...] style tags skipped
fn parseLrc(gpa: Allocator, text: []const u8) ![]Line {
    var list: std.ArrayList(Line) = .empty;
    var lines = mem.splitScalar(u8, text, '\n');
    while (lines.next()) |raw| {
        var rest = mem.trim(u8, raw, " \t\r");
        var stamps: [8]i64 = undefined;
        var n: usize = 0;
        while (rest.len > 0 and rest[0] == '[') {
            const close = mem.indexOfScalar(u8, rest, ']') orelse break;
            const us = parseStamp(rest[1..close]) orelse break;
            if (n < stamps.len) {
                stamps[n] = us;
                n += 1;
            }
            rest = rest[close + 1 ..];
        }
        for (stamps[0..n]) |us| try list.append(gpa, .{ .us = us, .text = mem.trim(u8, rest, " \t") });
    }
    mem.sort(Line, list.items, {}, struct {
        fn lt(_: void, a: Line, b: Line) bool {
            return a.us < b.us;
        }
    }.lt);
    return list.items;
}

/// the line sung at position, null before the first one
fn at(lines: []const Line, position: i64) ?[]const u8 {
    var found: ?[]const u8 = null;
    for (lines) |l| {
        if (l.us > position) break;
        found = l.text;
    }
    return found;
}

const Found = struct {
    syncedLyrics: ?[]const u8 = null,
};

fn lrclib(ctx: Ctx, gpa: Allocator, p: Player) ![]Line {
    const q = try std.fmt.allocPrint(gpa, "{s} {s}", .{ p.title, p.artist });
    const url = try std.fmt.allocPrint(gpa, "https://lrclib.net/api/search?q={s}", .{try urlEncode(gpa, q)});
    const body = try fetch(ctx, gpa, url);
    const found = try std.json.parseFromSliceLeaky([]Found, gpa, body, .{ .ignore_unknown_fields = true });
    // the first hit is not always synced
    for (found) |f| if (f.syncedLyrics) |lrc| return parseLrc(gpa, lrc);
    return &.{};
}

/// the v= of a youtube watch url, or a youtu.be id
fn youtubeId(url: []const u8) ?[]const u8 {
    const rest = if (mem.indexOf(u8, url, "youtu.be/")) |i|
        url[i + "youtu.be/".len ..]
    else if (mem.indexOf(u8, url, "youtube.com/watch?")) |i| blk: {
        const q = url[i + "youtube.com/watch?".len ..];
        var params = mem.splitScalar(u8, q[0 .. mem.indexOfScalar(u8, q, '#') orelse q.len], '&');
        while (params.next()) |kv| if (mem.startsWith(u8, kv, "v=")) break :blk kv[2..];
        return null;
    } else return null;
    const id = rest[0 .. mem.indexOfAny(u8, rest, "?&#/") orelse rest.len];
    return if (id.len > 0) id else null;
}

/// mozilla's lz4 files: "mozLz40\0", the decompressed size, then one lz4 block
fn mozLz4(gpa: Allocator, data: []const u8) ![]u8 {
    if (data.len < 12 or !mem.eql(u8, data[0..8], "mozLz40\x00")) return error.NotMozLz4;
    const out = try gpa.alloc(u8, mem.readInt(u32, data[8..12], .little));
    return out[0..try lz4Block(out, data[12..])];
}

fn lz4Block(out: []u8, src: []const u8) !usize {
    var i: usize = 0;
    var o: usize = 0;
    while (i < src.len) {
        const token = src[i];
        i += 1;
        var lit: usize = token >> 4;
        if (lit == 15) while (i < src.len) {
            lit += src[i];
            i += 1;
            if (src[i - 1] != 255) break;
        };
        if (i + lit > src.len or o + lit > out.len) return error.Corrupt;
        @memcpy(out[o..][0..lit], src[i..][0..lit]);
        i += lit;
        o += lit;
        // the last sequence has literals only
        if (i == src.len) break;
        if (i + 2 > src.len) return error.Corrupt;
        const offset: usize = mem.readInt(u16, src[i..][0..2], .little);
        i += 2;
        var len: usize = token & 15;
        if (len == 15) while (i < src.len) {
            len += src[i];
            i += 1;
            if (src[i - 1] != 255) break;
        };
        len += 4;
        if (offset == 0 or offset > o or o + len > out.len) return error.Corrupt;
        // matches may overlap what they copy, so byte by byte
        for (0..len) |k| out[o + k] = out[o - offset + k];
        o += len;
    }
    return o;
}

/// the newest recovery.jsonlz4 of any firefox, zen or librewolf profile
fn sessionFile(ctx: Ctx, gpa: Allocator) !?[]const u8 {
    const home = ctx.env.get("HOME") orelse return null;
    var best: ?[]const u8 = null;
    var best_mtime: i96 = 0;
    for ([_][]const u8{ ".zen", ".mozilla/firefox", ".librewolf" }) |base| {
        const root = try std.fs.path.join(gpa, &.{ home, base });
        var dir = Io.Dir.cwd().openDir(ctx.io, root, .{ .iterate = true }) catch continue;
        defer dir.close(ctx.io);
        var it = dir.iterate();
        while (it.next(ctx.io) catch null) |entry| {
            if (entry.kind != .directory) continue;
            const path = try std.fs.path.join(gpa, &.{ root, entry.name, "sessionstore-backups", "recovery.jsonlz4" });
            const st = Io.Dir.cwd().statFile(ctx.io, path, .{}) catch continue;
            if (best == null or st.mtime.nanoseconds > best_mtime) {
                best = path;
                best_mtime = st.mtime.nanoseconds;
            }
        }
    }
    return best;
}

/// the url of the tab looked at last, in the selected window
fn firefoxUrl(ctx: Ctx, gpa: Allocator) !?[]const u8 {
    const path = try sessionFile(ctx, gpa) orelse return null;
    const raw = try Io.Dir.cwd().readFileAlloc(ctx.io, path, gpa, .limited(256 << 20));
    const json = try std.json.parseFromSliceLeaky(std.json.Value, gpa, try mozLz4(gpa, raw), .{});

    const windows = (json.object.get("windows") orelse return null).array.items;
    if (windows.len == 0) return null;
    const selected: usize = if (json.object.get("selectedWindow")) |s| @intCast(@max(s.integer, 1)) else 1;
    const window = windows[@min(selected, windows.len) - 1];

    var last: ?std.json.ObjectMap = null;
    var last_at: i64 = -1;
    for ((window.object.get("tabs") orelse return null).array.items) |tab| {
        const t = if (tab.object.get("lastAccessed")) |v| v.integer else 0;
        if (t > last_at) {
            last = tab.object;
            last_at = t;
        }
    }
    const tab = last orelse return null;
    const entries = (tab.get("entries") orelse return null).array.items;
    if (entries.len == 0) return null;
    const index: usize = if (tab.get("index")) |v| @intCast(@max(v.integer, 1)) else entries.len;
    const url = entries[@min(index, entries.len) - 1].object.get("url") orelse return null;
    return url.string;
}

const transcript_py =
    \\import sys
    \\from youtube_transcript_api import YouTubeTranscriptApi as Api
    \\try:
    \\    rows = [(s.start, s.text) for s in Api().fetch(sys.argv[1])]
    \\except AttributeError:
    \\    rows = [(s["start"], s["text"]) for s in Api.get_transcript(sys.argv[1])]
    \\for start, text in rows:
    \\    print(f"{start}\t{' '.join(text.split())}")
;

/// captions as "seconds\ttext" lines, cached per video, also when there are none
fn youtube(ctx: Ctx, gpa: Allocator, id: []const u8) ![]Line {
    const name = try std.fmt.allocPrint(gpa, "yt-{s}", .{id});
    const text = ctx.cache.readFileAlloc(ctx.io, name, gpa, .limited(16 << 20)) catch |err| blk: {
        if (err != error.FileNotFound) return err;
        const res = try std.process.run(gpa, ctx.io, .{
            .argv = &.{ "python3", "-c", transcript_py, id },
            .timeout = .{ .duration = .{ .raw = python_timeout, .clock = .awake } },
        });
        const out = if (res.term == .exited and res.term.exited == 0) res.stdout else "";
        try ctx.cache.writeFile(ctx.io, .{ .sub_path = name, .data = out });
        break :blk out;
    };

    var list: std.ArrayList(Line) = .empty;
    var lines = mem.tokenizeScalar(u8, text, '\n');
    while (lines.next()) |line| {
        const tab = mem.indexOfScalar(u8, line, '\t') orelse continue;
        const sec = std.fmt.parseFloat(f64, line[0..tab]) catch continue;
        try list.append(gpa, .{ .us = @intFromFloat(sec * std.time.us_per_s), .text = line[tab + 1 ..] });
    }
    return list.items;
}

/// timed lines for what the player is on, empty when there are none
fn lookup(ctx: Ctx, gpa: Allocator, p: Player) ![]Line {
    if (p.album.len > 0 or p.isSpotify()) return lrclib(ctx, gpa, p);
    const url = if (p.url.len > 0) p.url else if (p.isFirefox()) try firefoxUrl(ctx, gpa) orelse "" else "";
    if (youtubeId(url)) |id| return youtube(ctx, gpa, id);
    return &.{};
}

/// lyrics of the song last looked up, kept while it plays
const Song = struct {
    arena: std.heap.ArenaAllocator,
    key: []const u8 = "",
    lines: []Line = &.{},
};

fn current(ctx: Ctx, gpa: Allocator, song: *Song) !?[]const u8 {
    const p = pick(try players(ctx, gpa)) orelse return null;
    const key = try p.key(gpa);
    if (!mem.eql(u8, key, song.key)) {
        _ = song.arena.reset(.retain_capacity);
        const a = song.arena.allocator();
        song.key = try a.dupe(u8, key);
        song.lines = lookup(ctx, a, p) catch |err| blk: {
            std.log.warn("{s}: {t}", .{ p.name, err });
            break :blk &.{};
        };
    }
    const text = at(song.lines, p.position) orelse try p.fallback(gpa);
    if (ctx.env.get("PRINT_PLAYER") != null) return try std.fmt.allocPrint(gpa, "{s}\n{s}", .{ p.name, text });
    return text;
}

fn cacheDir(io: Io, env: *const std.process.Environ.Map, gpa: Allocator) !Io.Dir {
    const path = if (env.get("XDG_CACHE_HOME")) |x|
        try std.fs.path.join(gpa, &.{ x, "lyrics" })
    else
        try std.fs.path.join(gpa, &.{ env.get("HOME") orelse return error.NoHome, ".cache", "lyrics" });
    return Io.Dir.cwd().createDirPathOpen(io, path, .{});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();

    var follow = false;
    for ((try init.minimal.args.toSlice(arena))[1..]) |arg| {
        if (mem.eql(u8, arg, "-f") or mem.eql(u8, arg, "--follow")) {
            follow = true;
        } else {
            std.log.err("usage: lyrics.zig [-f|--follow]", .{});
            std.process.exit(2);
        }
    }

    var client: std.http.Client = .{ .allocator = init.gpa, .io = io };
    defer client.deinit();
    try client.initDefaultProxies(arena, init.environ_map);

    const ctx: Ctx = .{
        .io = io,
        .env = init.environ_map,
        .client = &client,
        .cache = try cacheDir(io, init.environ_map, arena),
    };

    var buf: [4096]u8 = undefined;
    var stdout_writer = Io.File.stdout().writer(io, &buf);
    const stdout = &stdout_writer.interface;

    var song: Song = .{ .arena = .init(init.gpa) };
    defer song.arena.deinit();
    var tick: std.heap.ArenaAllocator = .init(init.gpa);
    defer tick.deinit();
    var shown: std.ArrayList(u8) = .empty;
    defer shown.deinit(init.gpa);

    while (true) {
        _ = tick.reset(.retain_capacity);
        const text = try current(ctx, tick.allocator(), &song) orelse "";
        if (!follow) {
            if (text.len > 0) try stdout.print("{s}\n", .{text});
            try stdout.flush();
            return;
        }
        if (!mem.eql(u8, text, shown.items)) {
            try stdout.print("{s}\n", .{text});
            try stdout.flush();
            shown.clearRetainingCapacity();
            try shown.appendSlice(init.gpa, text);
        }
        try io.sleep(follow_interval, .awake);
    }
}

test "lrc lines" {
    const gpa = std.testing.allocator;
    var arena: std.heap.ArenaAllocator = .init(gpa);
    defer arena.deinit();
    const lines = try parseLrc(arena.allocator(),
        \\[ar:Somebody]
        \\[00:01.50] first
        \\[00:10.00][01:02.345] chorus
        \\[00:05.0]
        \\no stamp
    );
    try std.testing.expectEqual(@as(usize, 4), lines.len);
    try std.testing.expectEqual(@as(i64, 1_500_000), lines[0].us);
    try std.testing.expectEqual(@as(i64, 62_345_000), lines[3].us);
    try std.testing.expect(at(lines, 1_000_000) == null);
    try std.testing.expectEqualStrings("first", at(lines, 4_999_999).?);
    try std.testing.expectEqualStrings("", at(lines, 5_000_000).?);
    try std.testing.expectEqualStrings("chorus", at(lines, 999_000_000).?);
}

test "youtube ids" {
    try std.testing.expectEqualStrings("dQw4w9WgXcQ", youtubeId("https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=42s").?);
    try std.testing.expectEqualStrings("dQw4w9WgXcQ", youtubeId("https://music.youtube.com/watch?list=x&v=dQw4w9WgXcQ").?);
    try std.testing.expectEqualStrings("dQw4w9WgXcQ", youtubeId("https://youtu.be/dQw4w9WgXcQ?si=abc").?);
    try std.testing.expect(youtubeId("https://www.youtube.com/watch?list=x") == null);
    try std.testing.expect(youtubeId("https://example.com/") == null);
}

test "url encoding" {
    const gpa = std.testing.allocator;
    const s = try urlEncode(gpa, "AC/DC & me~");
    defer gpa.free(s);
    try std.testing.expectEqualStrings("AC%2FDC%20%26%20me~", s);
}

test "lz4 block with an overlapping match" {
    // "ab" then a 6 byte match at offset 2, then "!" as the last literals
    const block = [_]u8{ 0x22, 'a', 'b', 2, 0, 0x10, '!' };
    var out: [9]u8 = undefined;
    const n = try lz4Block(&out, &block);
    try std.testing.expectEqualStrings("abababab!", out[0..n]);
}
