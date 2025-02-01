#!/usr/bin/env bash

img_log_file=~/log/img.log
img_dir=~/Pictures/walls/walls-main/anime
img_file_index=~/.cache/imgIndex.txt
bg_id_file=/tmp/bg_id
bg_id=""

sed -i '/^$/d' $img_log_file

if [ ! -f $img_log_file ]; then
	mkdir -p "$(dirname "$img_log_file")"
	touch $img_log_file
fi

if [ -f $bg_id_file ]; then
	bg_id="$(cat "$bg_id_file")"
fi

if [ ! -f $img_file_index ]; then
	ls -1 $img_dir/* >$img_file_index
fi

function setbg() {
	img=$1
	mes=""

	if [[ -n ${GO_WALL} ]]; then
		if [[ -n ${GO_WALL_INVERT} ]]; then
			gowall invert "$img"
			mes+=inverted
		fi
		gowall convert "$img" -t "${GO_WALL:-nix}"
		mes+=" $GO_WALL "
		img="$HOME/Pictures/gowall/$(basename "$img")"
	fi

	if ! [ -f "$img" ]; then
		notify-send "Image file does not exist '$img'"
		echo "Image file does not exist '$img'" 1>&2
	fi

	if [[ $XDG_SESSION_TYPE == "x11" ]]; then
		feh --bg-fill "$img"

		echo "$img"
		echo "$img" >>$img_log_file

		if [[ -z ${bg_id} ]]; then
			notify-send "Set bg" "$img" --icon "$img" -p -r "$bg_id" >"$bg_id_file"
		else
			notify-send "Set bg" "$img" --icon "$img" -p >"$bg_id_file"
		fi
	elif [[ $XDG_SESSION_TYPE == "wayland" ]]; then
		if pgrep -x "hyprpaper" >/dev/null; then
			hyprctl hyprpaper preload "$img"
			hyprctl hyprpaper wallpaper "eDP-1,$img"
		else
			if pgrep -x "swww-daemon" >/dev/null; then
				swww img "$img" --transition-type wipe 1>&2 2>/dev/null
			else
				if pgrep -x "swaybg" >/dev/null; then
					killall -9 swaybg 2>/dev/null
					swaybg -i "$img" -m fill 1>&2 2>/dev/null &
					disown
				fi
			fi
		fi

		echo "$img"
		echo "$img" >>$img_log_file

		if [[ -n ${bg_id} ]]; then
			notify-send "Set bg" "$mes $img" --icon "$img" -p -r "$bg_id" >"$bg_id_file"
		else
			notify-send "Set bg" "$mes $img" --icon "$img" -p >"$bg_id_file"
		fi

	else
		echo "No XDG_SESSION_TYPE:'$XDG_SESSION_TYPE'"
	fi
}
