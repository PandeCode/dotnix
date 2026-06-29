#!/usr/bin/env bash

if [[ $XDG_SESSION_TYPE == "x11" ]]; then
	dunstctl set-paused false
elif [[ $XDG_SESSION_TYPE == "wayland" ]]; then
	swaync-client -df
fi
