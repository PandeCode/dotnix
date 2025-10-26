#!/usr/bin/env bash
LC_ALL=C

if [[ $XDG_SESSION_TYPE == "x11" ]]; then
	notify-send "TODO"
elif [[ $XDG_SESSION_TYPE == "wayland" ]]; then

# Ensure hyprlock is installed
if ! command -v hyprlock &>/dev/null; then
	echo "hyprlock is not installed."
	exit 1
fi

if pgrep -x "hyprlock" &>/dev/null; then
	exit
fi

# Get a random image from the walls directory
WALLPAPER=$(SILENT=1 bg.sh get-last)

# Create a temporary hyprlock config
TMP_CONFIG=$(mktemp)

cat >"$TMP_CONFIG" <<EOF
# Hyprlock temporary config

background {
	path = $WALLPAPER
	blur_passes = 3
	blur_size = 5
}

input-field {
	monitor = eDP-1
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
	monitor = eDP-1
	text = <b>\$USER</b>
	color = rgba(ffffffff)
	font_size = 20
	position = 0, -100
	halign = center
}

label {
	monitor = eDP-1
	text = $(date +"%A, %B %d - %I:%M %p")
	color = rgba(ddddddff)
	font_size = 16
	position = 0, 100
	halign = center
}

EOF

# Lock with the temporary config
hyprlock --config "$TMP_CONFIG"

# Clean up after unlock
rm -f "$TMP_CONFIG"

fi
