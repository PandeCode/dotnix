#!/usr/bin/env bash

if pidof waybar >/dev/null; then
	pkill -9 waybar
else
	if pidof niri > /dev/null; then
		waybar -c $(get_niri_waybar.sh) &
		disown
	else
		waybar &
		disown
	fi
fi
