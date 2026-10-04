mode=${1:-screen}

case $mode in
screen | area) ;;
*)
	echo "usage: screenshot screen|area" >&2
	exit 2
	;;
esac

dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$dir"
read -r weekday day time < <(date "+%A %-d %H_%M_%S")
case $day in
1 | 21 | 31) suffix=st ;;
2 | 22) suffix=nd ;;
3 | 23) suffix=rd ;;
*) suffix=th ;;
esac
# e.g. Monday_5th_17_23_01.png
file="$dir/${weekday}_$day${suffix}_$time.png"

if [[ -n ${WAYLAND_DISPLAY:-} ]]; then
	if [[ $mode == area ]]; then
		# escape in slurp cancels: take nothing
		geometry=$(slurp) || exit 0
		grim -g "$geometry" "$file"
	else
		grim "$file"
	fi
	wl-copy --type image/png <"$file"
else
	if [[ $mode == area ]]; then
		maim --select --hidecursor "$file" || exit 0
	else
		maim --hidecursor "$file"
	fi
	xclip -selection clipboard -target image/png <"$file"
fi

notify-send --icon "$file" "Screenshot" "$file"
