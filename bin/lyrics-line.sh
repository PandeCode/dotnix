#!/usr/bin/env bash

# jq
# playerctl
# python3 with youtube-transcript-api
# pip install youtube-transcript-api # also present in nixpkgs by the same name

PLAYER="${1:-spotify}"

CACHE_DIR=$HOME/.cache/lyrics
mkdir -p "$CACHE_DIR"

trim() {
	local var="$*"
	var="${var#"${var%%[![:space:]]*}"}"
	var="${var%"${var##*[![:space:]]}"}"
	printf '%s' "$var"
}

hash() {
	echo -n "$1" | md5sum | awk '{print $1}'
}

fetch_with_cache() {
	uri="$1"
	file_path="$CACHE_DIR/$(hash "$uri")"

	if [ -f "$file_path" ]; then
		res=$(cat "$file_path")
		echo "$res"
	else

		res=$(curl -s "$1")

		if [[ -z "$res" ]]; then
			return 1
		fi

		echo "$res" >"$file_path"
		echo "$res"
	fi
}

get_title_artists() {
	playerctl -p $PLAYER metadata --format "{{title}} {{artist}}" | jq -sRr @uri
}

lrclib() {
	url="https://lrclib.net/api/search?q=$(get_title_artists)"
	fetch_with_cache "$url" | jq ".[0].syncedLyrics" -r
}

netease() {
	song_id=$(fetch_with_cache "https://music.xianqiao.wang/neteaseapiv2/search?limit=10&type=1&keywords=$(get_title_artists)" | jq ".result.songs[0].id")
	fetch_with_cache "https://music.xianqiao.wang/neteaseapiv2/lyric?id=$song_id" | jq ".lrc.lyric" -r
}

get_position() {
	playerctl -p $PLAYER metadata --format "{{position}}"
}

convert_to_microseconds() {
	local timestamp=$1
	timestamp=${timestamp//[\[\]]/}

	IFS=":." read -r minutes seconds milliseconds <<<"$timestamp"

	minutes=${minutes#0}
	seconds=${seconds#0}
	milliseconds=${milliseconds#0}

	[ -z "$minutes" ] && minutes=0
	[ -z "$seconds" ] && seconds=0
	[ -z "$milliseconds" ] && milliseconds=0

	local total_microseconds=$(((\
		minutes * 60 * 1000000) + (\
		seconds * 1000000) + (\
		milliseconds * 1000)))

	echo "$total_microseconds"
}

current_line() {
	prev=""
	position=$1
	while IFS= read -r line; do
		[ -z "$line" ] && continue

		if [[ $line =~ ^\[[0-9:.]+\] ]]; then
			timestamp=${line%%\]*}"]"
			content=${line#*]}

			microseconds=$(convert_to_microseconds "$timestamp")

			if ((position < microseconds)); then
				trim "$prev"
				return
			fi
			prev=$content
		fi
	done

}

youtube() {
	id=$1

	file_path=$CACHE_DIR/$id

	if [ -f "$file_path" ]; then
		res=$(cat "$file_path")
		echo "$res"
	else
		res=$(
			python3 <<EOF
from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api.formatters import TextFormatter

def convert_to_timestamp_format(seconds):
    """Convert seconds to [MM:SS.MS] format"""
    minutes = seconds // 60
    seconds_remainder = seconds % 60
    # Format with exactly 2 decimal places for milliseconds
    return f"[{minutes:02d}:{seconds_remainder:05.2f}]"

def convert_json_to_timestamp_format(json_str):
    formatted_lines = []
    for entry in json_str:
        timestamp = convert_to_timestamp_format(int(entry['start']))
        formatted_lines.append(f"{timestamp} {entry['text']}")
    return '\n'.join(formatted_lines)

t = YouTubeTranscriptApi.get_transcript('$id')

print(convert_json_to_timestamp_format(t), end='\n')
EOF
		)
		echo "$res" >"$file_path"
		echo "res $res"
	fi
}

# (lrclib || netease) | current_line "$(playerctl -p "$PLAYER" metadata --format '{{ position }}')"

if [ "$PLAYER" == "youtube" ]; then
	youtube lQ2raQCSJRE | current_line $(playerctl -p chromium metadata --format '{{ position }}')
else
	if pgrep -x "spotify" >/dev/null; then
		lrclib | current_line "$(playerctl -p spotify metadata --format '{{ position }}')"
	else
		album=$(playerctl -p chromium metadata xesam:album | tr -d '\n')
		PLAYER=chromium
		if [ -z "$album" ]; then
			playerctl -p $PLAYER metadata --format "{{title}} {{artist}}"
		else
			lrclib | current_line "$(playerctl -p chromium metadata --format '{{ position }}')"
		fi
	fi
fi
