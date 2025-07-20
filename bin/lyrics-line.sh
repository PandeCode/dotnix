#!/usr/bin/env bash

# jq
# playerctl
# python3 with youtube-transcript-api
# pip install youtube-transcript-api # also present in nixpkgs by the same name

PLAYER="${1:-spotify}"
FIREFOX=~/.zen/hbvavekk.School/sessionstore-backups/recovery.jsonlz4
CACHE_DIR=$HOME/.cache/lyrics
LOCK_DIR=$HOME/.cache/lyrics/locks
mkdir -p "$CACHE_DIR"
mkdir -p "$LOCK_DIR"

get_id() {
	url=$(dejsonlz4 "$FIREFOX" | jq -r ".windows[0].tabs | sort_by(.lastAccessed)[-1] | .entries[.index-1] | .url")

	if [[ "$url" =~ ^https://www\.youtube\.com/watch\?v= ]]; then
		echo "$url" | perl -pe 's|https:\/\/www\.youtube\.com\/watch\?v=||'
	else
		echo "Error: The URL is not from YouTube." >&2
		return 1
	fi
}

trim() {
	local var="$*"
	var="${var#"${var%%[![:space:]]*}"}"
	var="${var%"${var##*[![:space:]]}"}"
	printf '%s' "$var"
}

hash() {
	echo -n "$1" | md5sum | awk '{print $1}'
}

# Function to acquire lock
acquire_lock() {
	local lock_name="$1"
	local lock_file="$LOCK_DIR/$lock_name.lock"
	local max_wait=30 # Maximum wait time in seconds
	local waited=0

	# Try to create the lock file
	while ! mkdir "$lock_file" 2>/dev/null; do
		# Check if we've waited too long
		if [ $waited -ge $max_wait ]; then
			echo "Timeout waiting for lock: $lock_name" >&2
			return 1
		fi

		# Wait a bit before retrying
		sleep 0.5
		waited=$((waited + 1))
	done

	# Store the PID in the lock file
	echo $$ >"$lock_file/pid"

	# Set trap to release lock on exit
	trap "rm -rf '$lock_file' 2>/dev/null || true" EXIT

	return 0
}

# Function to release lock
release_lock() {
	local lock_name="$1"
	local lock_file="$LOCK_DIR/$lock_name.lock"

	rm -rf "$lock_file" 2>/dev/null || true

	# Remove the specific trap for this lock
	trap - EXIT
}

fetch_with_cache() {
	uri="$1"
	lock_name=$(hash "$uri")
	file_path="$CACHE_DIR/$(hash "$uri")"

	if [ -f "$file_path" ]; then
		res=$(cat "$file_path")
		echo "$res"
	else
		# Acquire lock before fetching
		if ! acquire_lock "$lock_name"; then
			# If we couldn't get the lock, check if the file appeared while waiting
			if [ -f "$file_path" ]; then
				res=$(cat "$file_path")
				echo "$res"
				return 0
			fi
			return 1
		fi

		# Double-check if another process created the file while we were waiting for the lock
		if [ -f "$file_path" ]; then
			res=$(cat "$file_path")
			echo "$res"
			release_lock "$lock_name"
			return 0
		fi

		res=$(curl -s "$1")

		if [[ -z "$res" ]]; then
			release_lock "$lock_name"
			return 1
		fi

		echo "$res" >"$file_path"
		echo "$res"

		# Release the lock
		release_lock "$lock_name"
	fi
}

get_title_artists() {
	playerctl -p "$PLAYER" metadata --format "{{title}} {{artist}}" | jq -sRr @uri
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
	playerctl -p "$PLAYER" metadata --format "{{position}}"
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
	lock_name="youtube_$id"
	file_path="$CACHE_DIR/$id"

	if [ -f "$file_path" ]; then
		res=$(cat "$file_path")
		echo "$res"
	else
		# Acquire lock before fetching
		if ! acquire_lock "$lock_name"; then
			# If we couldn't get the lock, check if the file appeared while waiting
			if [ -f "$file_path" ]; then
				res=$(cat "$file_path")
				echo "$res"
				return 0
			fi
			return 1
		fi

		# Double-check if another process created the file while we were waiting for the lock
		if [ -f "$file_path" ]; then
			res=$(cat "$file_path")
			echo "$res"
			release_lock "$lock_name"
			return 0
		fi

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
if [ $? -eq 0 ]; then
	echo "$res" >"$file_path"
fi

# Release the lock
release_lock "$lock_name"
echo "$res"
	fi
}

# Function to fetch lyrics for a given player
handle_player() {
	local player="$1"
	local album

	if [ -z "${PRINT_PLAYER}" ]; then
		:
	else
		echo "$player"
	fi

	case "$player" in
		spotify | .spotify-wrappe)
			PLAYER=spotify
			if ! lrclib | current_line "$(get_position)"; then
				playerctl metadata --format "{{title}} - {{artist}}"
			fi
			;;
		spotifyd | spotifyd*)
			PLAYER=spotifyd
			if ! lrclib | current_line "$(get_position)"; then
				playerctl metadata --format "{{title}} - {{artist}}"
			fi

			;;
		spotify_player | spotify_player*)
			PLAYER=spotify_player
			if ! lrclib | current_line "$(get_position)"; then
				playerctl metadata --format "{{title}} - {{artist}}"
			fi
			;;
		chromium)
			PLAYER=chromium
			album=$(playerctl -p $PLAYER metadata xesam:album | tr -d '\n')
			if [ -z "$album" ]; then
				playerctl -p $PLAYER metadata --format "{{title}} {{artist}}"
			else
				lrclib | current_line "$(get_position)"
			fi
			;;
		firefox)
			PLAYER=firefox
			album=$(playerctl -p $PLAYER metadata xesam:album | tr -d '\n')
			if [ -z "$album" ]; then
				id=$(get_id)
				if [ $? -eq 0 ]; then
					subs=$(youtube "$id")
					echo "$subs" | current_line "$(get_position)"
				fi
			else
				lrclib | current_line "$(get_position)"
			fi
			;;
	esac
}

# Priority: Playing status gets first dibs
for player in $(playerctl -l 2>/dev/null); do
	if [ "$(playerctl -p "$player" status 2>/dev/null)" = "Playing" ]; then
		handle_player "$player"
		exit 0
	fi
done

# Fallback: Process name check
declare -A fallback=(
	["spotifyd"]="spotifyd"
	["spotify"]="spotify .spotify-wrapper"
	["spotify_player"]="spotify_player"
	["chromium"]="google-chrome-stable"
	["firefox"]="firefox .zen-wrapped .zen-twilight-w zen"
)

for player in "${!fallback[@]}"; do
	read -ra procs <<<"${fallback[$player]}"
	for proc in "${procs[@]}"; do
		if pgrep -fx "$proc" 2>/dev/null >/dev/null || pgrep -x "$proc" 2>/dev/null >/dev/null; then
			handle_player "$player"
			exit 0
		fi
	done
done
