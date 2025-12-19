#!/usr/bin/env bash

wm_list=("awesome" "niri" "i3" "sway" "dwm" "xmonad" "Hyprland" "river" "fht-compositor")

is_running() {
	pgrep -x "$1" >/dev/null 2>&1
}

for wm in "${wm_list[@]}"; do
	if is_running "$wm"; then
		echo "$wm"
		exit 0
	fi
done

echo "Unknown or unsupported window manager"
exit 1
