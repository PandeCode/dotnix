#!/usr/bin/env bash

get_active_player() {
	local priority=("spotifyd" "spotify_player" "spotify" "firefox" "chrome")
	local active_players
	IFS=$'\n' read -d '' -r -a active_players < <(playerctl -l 2>/dev/null && printf '\0')

	for prefix in "${priority[@]}"; do
		for player in "${active_players[@]}"; do
			if [[ "$player" == "$prefix"* ]]; then
				if [[ $(playerctl -p "$player" status 2>/dev/null) == "Playing" ]]; then
					echo "$player"
					return 0
				fi
			fi
		done
	done

	for prefix in "${priority[@]}"; do
		for player in "${active_players[@]}"; do
			if [[ "$player" == "$prefix"* ]]; then
				echo "$player"
				return 0
			fi
		done
	done

	return 1
}

# Check if player override is provided
if [[ -n "$1" ]]; then
	player="$1"
else
	player="$(get_active_player)"
fi

# Try to get art from selected player
chosen_art="$(playerctl -p "$player" metadata mpris:artUrl 2>/dev/null)"

# Fallback if nothing found: check other paused players
if [[ -z "$chosen_art" ]]; then
	declare -A player_art
	players=($(playerctl -l 2>/dev/null))

	for p in "${players[@]}"; do
		status=$(playerctl -p "$p" status 2>/dev/null)
		if [[ "$status" == "Paused" ]]; then
			art=$(playerctl -p "$p" metadata mpris:artUrl 2>/dev/null)
			if [[ -n "$art" ]]; then
				chosen_art="$art"
				break
			fi
		fi
	done
fi

# Exit if still nothing
if [[ -z "$chosen_art" ]]; then
	exit
fi

# Handle file:// or remote URLs
if [[ "$chosen_art" == file://* ]]; then
	path="${chosen_art#file://}"
	echo -n "$path"

elif [[ "$chosen_art" == https://* || "$chosen_art" == http://* ]]; then
	CAD=~/.cache/spotifyPictureCache
	mkdir -p "$CAD"
	cd "$CAD" || exit

	filename=$(basename "$chosen_art")
	if [[ ! -f "$filename" ]]; then
		wget -c "$chosen_art" -q
	fi

	echo -n "$CAD/$filename"
fi
