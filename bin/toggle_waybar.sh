#!/usr/bin/env bash

if pidof waybar >/dev/null; then
	pkill -9 waybar
else
	if pidof niri >/dev/null; then
		waybar &
		disown
	else
		notify-send "new wm ?"
	fi
fi
