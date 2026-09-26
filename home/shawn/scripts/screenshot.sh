# screenshot screen|area: saves to ~/Pictures/Screenshots, copies the image
# and shows a notification. grim and slurp on wayland, maim on x11
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
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

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
