#!/usr/bin/env bash


fetch_art() {
    local player=$1
    local status
    status=$(playerctl -p "$player" status 2>/dev/null)

    if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
        album_art=$(playerctl -p "$player" metadata mpris:artUrl 2>/dev/null)
        if [[ -n "$album_art" ]]; then
            echo "$status|$player|$album_art"
        fi
    fi
}

declare -A player_art
players=($(playerctl -l 2>/dev/null))

# Check each available player
for p in "${players[@]}"; do
    result=$(fetch_art "$p")
    if [[ -n "$result" ]]; then
        status="${result%%|*}"
        rest="${result#*|}"
        player="${rest%%|*}"
        art="${rest#*|}"
        player_art["$player"]="$status|$art"
    fi
done

# Prioritize 'Playing' first
chosen_art=""
for p in "${players[@]}"; do
    data=${player_art["$p"]}
    if [[ $data == Playing* ]]; then
        chosen_art="${data#*|}"
        break
    fi
done

# Fallback to 'Paused' if no 'Playing'
if [[ -z $chosen_art ]]; then
    for p in "${players[@]}"; do
        data=${player_art["$p"]}
        if [[ $data == Paused* ]]; then
            chosen_art="${data#*|}"
            break
        fi
    done
fi

# Exit if still empty
if [[ -z $chosen_art ]]; then
    exit
fi

# Local file (e.g., from browsers)
if [[ "$chosen_art" == file://* ]]; then
    path="${chosen_art/file:\/\//}"
    set_cover "$path"
    exit
fi

# Remote art cache
CAD=~/.cache/spotifyPictureCache
mkdir -p "$CAD"
cd "$CAD" || exit

filename=$(basename "$chosen_art")
if [[ ! -f "$filename" ]]; then
    wget -c "$chosen_art" -q
fi

echo "$CAD/$filename"
