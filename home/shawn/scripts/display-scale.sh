# in makes everything bigger, out smaller, on every session
direction=${1:-}

case $direction in
in | out | reset) ;;
*)
	echo "usage: display-scale in|out|reset" >&2
	exit 2
	;;
esac

if [[ -n ${WAYLAND_DISPLAY:-} ]]; then
	read -r output scale < <(wlr-randr --json | jq -r 'first(.[] | select(.enabled)) | "\(.name) \(.scale)"')
	case $direction in
	in) scale=$(awk -v s="$scale" 'BEGIN { print (s + 0.25 > 3) ? 3 : s + 0.25 }') ;;
	out) scale=$(awk -v s="$scale" 'BEGIN { print (s - 0.25 < 0.5) ? 0.5 : s - 0.25 }') ;;
	reset) scale=1 ;;
	esac
	wlr-randr --output "$output" --scale "$scale"
else
	# xrandr scales the framebuffer: below 1 shows less, so everything is bigger
	output=$(xrandr | awk '/ connected/ { print $1; exit }')
	case $direction in
	in) scale=0.8x0.8 ;;
	out) scale=1.2x1.2 ;;
	reset) scale=1x1 ;;
	esac
	xrandr --output "$output" --scale "$scale"
fi
