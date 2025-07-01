#!/usr/bin/env bash

if pidof waybar >/dev/null; then
	pkill -9 waybar
else
	waybar &
	disown
fi
