#!/usr/bin/env bash

# Options
screen="screen"
area="area"
window="window"

# Variable passed to rofi
options="$screen\n$area\n$window"

chosen="$(echo -e "$options" | rofi -p '' -dmenu -selected-row 1)"
case $chosen in
"$screen")
	scrot 'Screenshot_%Y-%m-%d-%S_$wx$h.png'
	;;
"$area")
	scrot -s 'Screenshot_%Y-%m-%d-%S_$wx$h.png'
	;;
"$window")
	sleep 1
	scrot -u 'Screenshot_%Y-%m-%d-%S_$wx$h.png'
	;;
esac
