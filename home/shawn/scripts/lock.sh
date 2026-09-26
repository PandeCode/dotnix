if pgrep -x hyprlock >/dev/null || pgrep -x i3lock >/dev/null; then
	exit 0
fi

if [[ -z ${WAYLAND_DISPLAY:-} ]]; then
	exec i3lock --nofork --color=000000
fi

wallpaper=$(SILENT=1 bg.sh get-last 2>/dev/null || true)
config=$(mktemp)
trap 'rm -f "$config"' EXIT

cat >"$config" <<CONFIG
background {
	path = ${wallpaper:-screenshot}
	blur_passes = 3
	blur_size = 5
}

input-field {
	size = 300, 60
	outline_thickness = 4
	dots_center = true
	outer_color = rgba(ffffff99)
	inner_color = rgba(00000099)
	font_color = rgba(ffffffff)
	fade_on_empty = true
	placeholder_text = <span foreground="##aaaaaa">Password...</span>
	position = 0, -20
	halign = center
}

label {
	text = <b>\$USER</b>
	color = rgba(ffffffff)
	font_size = 20
	position = 0, -100
	halign = center
}

label {
	text = $(date +"%A, %B %d - %I:%M %p")
	color = rgba(ddddddff)
	font_size = 16
	position = 0, 100
	halign = center
}
CONFIG

hyprlock --config "$config"
