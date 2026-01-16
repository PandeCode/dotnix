#!/usr/bin/env bash

if [[ $XDG_SESSION_TYPE == "x11" ]]; then
	dunstctl set-paused true
elif [[ $XDG_SESSION_TYPE == "wayland" ]]; then
	swaync-client -dn
fi
