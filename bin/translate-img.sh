#!/usr/bin/env bash

if [[ $XDG_SESSION_TYPE == "x11" ]]; then
	notify-send "TODO" "for x11"
elif [[ $XDG_SESSION_TYPE == "wayland" ]]; then
	grimblast copysave area /tmp/trans.png
else
	notify-send "TODO" "for ???"
fi

text=$(tesseract /tmp/trans.png - -l eng)

if [[ $XDG_SESSION_TYPE == "x11" ]]; then
	echo "$text" | xclip -selection clipboard
elif [[ $XDG_SESSION_TYPE == "wayland" ]]; then
	echo "$text" | wl-copy
else
	notify-send "TODO" "for ???"
fi

notify-send "Tranlation (image)" "$text" -i /tmp/trans
