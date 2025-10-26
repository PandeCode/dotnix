#!/usr/bin/env bash

if [[ $XDG_SESSION_TYPE == "x11" ]]; then
	notify-send "Tranlation" "$(trans "$(xclip -selection clipboard -o)")"
elif [[ $XDG_SESSION_TYPE == "wayland" ]]; then
	notify-send "Tranlation" "$(trans "$(wl-paste)")"
else
	notify-send "TODO" "for ???"
fi
