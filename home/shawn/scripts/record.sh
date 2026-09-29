# a second press stops the recording
mode=${1:-screen}

case $mode in
screen | area) ;;
*)
	echo "usage: record screen|area" >&2
	exit 2
	;;
esac

state="${XDG_RUNTIME_DIR:-/tmp}/record"

if [[ -f $state.pid ]] && kill -0 "$(<"$state.pid")" 2>/dev/null; then
	kill -TERM "$(<"$state.pid")"
	file=$(<"$state.file")
	rm -f "$state.pid" "$state.file"
	if [[ -n ${WAYLAND_DISPLAY:-} ]]; then
		wl-copy <<<"$file"
	else
		xclip -selection clipboard <<<"$file"
	fi
	notify-send "Recording saved" "$file"
	exit 0
fi

dir="${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).mp4"

if [[ -n ${WAYLAND_DISPLAY:-} ]]; then
	if [[ $mode == area ]]; then
		geometry=$(slurp) || exit 0
		wf-recorder --audio -g "$geometry" -f "$file" &>/dev/null &
	else
		# wf-recorder asks on the terminal when there is more than one output
		output=$(wlr-randr --json | jq -r 'first(.[] | select(.enabled)) | .name')
		wf-recorder --audio -o "$output" -f "$file" &>/dev/null &
	fi
else
	if [[ $mode == area ]]; then
		read -r x y width height < <(slop -f "%x %y %w %h") || exit 0
	else
		x=0 y=0
		read -r width height < <(xdpyinfo | awk '/dimensions/ { split($2, size, "x"); print size[1], size[2] }')
	fi
	# x264 needs even dimensions
	ffmpeg -loglevel error -f x11grab -video_size "${width}x${height}" -i "$DISPLAY+$x,$y" \
		-f pulse -i default -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" "$file" &>/dev/null &
fi

echo $! >"$state.pid"
echo "$file" >"$state.file"
notify-send "Recording" "press again to stop"
