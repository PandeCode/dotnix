#!/usr/bin/env bash

metadata=$(playerctl --player=cider metadata)
artist=$(echo "$metadata" | grep "artist" | cut -d' ' -f3-)
title=$(echo "$metadata" | grep "title" | cut -d' ' -f3-)

status=$(playerctl --player="$1" status)

if [[ $status == "Playing" ]]; then
	icon=󰏤
elif [[ $status == "Paused" ]]; then
	icon=
fi

echo "$artist" "-" "$title" "$icon"
