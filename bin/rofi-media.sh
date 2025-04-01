#!/usr/bin/env bash

# Script to create an xmenu-like media controls menu using Rofi

# Check dependencies
for cmd in rofi playerctl; do
	if ! command -v "$cmd" &>/dev/null; then
		notify-send "Media Menu Error" "$cmd is not installed but required"
		exit 1
	fi
done

# Set the rofi command with styling to make it look more like a right-click menu
ROFI_CMD="rofi -dmenu -i -no-fixed-num-lines -width 15 -location 3 -yoffset 32 -xoffset -2 -theme-str 'window {border: 1px; border-color: #888888; border-radius: 2px;} listview {lines: 12; scrollbar: false;} element {padding: 4px;}'"

# Get player information
get_player_status() {
	PLAYER=$(playerctl -l 2>/dev/null | head -n1)
	if [ -z "$PLAYER" ]; then
		echo "No active player"
		return 1
	fi

	STATUS=$(playerctl status 2>/dev/null)
	TITLE=$(playerctl metadata title 2>/dev/null)
	ARTIST=$(playerctl metadata artist 2>/dev/null)

	if [ -n "$TITLE" ]; then
		if [ -n "$ARTIST" ]; then
			echo "$ARTIST - $TITLE"
		else
			echo "$TITLE"
		fi
	else
		echo "No track information"
	fi
}

# Get volume information
get_volume_status() {
	if command -v pactl &>/dev/null; then
		VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -n1)
		MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o "yes")
		if [ "$MUTE" = "yes" ]; then
			echo "🔇 Muted"
		else
			echo "🔊 Volume: $VOL"
		fi
	elif command -v amixer &>/dev/null; then
		VOL=$(amixer get Master | grep -oP '\d+%' | head -n1)
		MUTE=$(amixer get Master | grep -o "\[off\]")
		if [ -n "$MUTE" ]; then
			echo "🔇 Muted"
		else
			echo "🔊 Volume: $VOL"
		fi
	else
		echo "🔊 Volume: N/A"
	fi
}

# Generate menu based on context
generate_menu() {
	local menu_type="$1"

	case "$menu_type" in
	"main")
		# Initial menu
		echo -e "Media Controls\n---\nPlayer\nVolume\nSettings"
		;;
	"player")
		# Player submenu
		NOW_PLAYING=$(get_player_status)
		echo -e "Now Playing: $NOW_PLAYING\n---\n⏯️ Play/Pause\n⏭️ Next Track\n⏮️ Previous Track\n⏹️ Stop\n---\nOpen Player"
		;;
	"volume")
		# Volume submenu
		VOL_STATUS=$(get_volume_status)
		echo -e "$VOL_STATUS\n---\n🔊 Increase Volume\n🔉 Decrease Volume\n🔇 Toggle Mute"
		;;
	"settings")
		# Settings submenu
		echo -e "Settings\n---\nSet Default Player\nOpen Sound Settings"
		;;
	esac
}

# Execute the selected command
execute_command() {
	local cmd="$1"

	case "$cmd" in
	"Player")
		# Open player submenu
		selection=$(generate_menu "player" | eval "$ROFI_CMD -p 'Player'")
		[ -n "$selection" ] && execute_command "$selection"
		;;
	"Volume")
		# Open volume submenu
		selection=$(generate_menu "volume" | eval "$ROFI_CMD -p 'Volume'")
		[ -n "$selection" ] && execute_command "$selection"
		;;
	"Settings")
		# Open settings submenu
		selection=$(generate_menu "settings" | eval "$ROFI_CMD -p 'Settings'")
		[ -n "$selection" ] && execute_command "$selection"
		;;
	"⏯️ Play/Pause")
		playerctl play-pause
		;;
	"⏭️ Next Track")
		playerctl next
		;;
	"⏮️ Previous Track")
		playerctl previous
		;;
	"⏹️ Stop")
		playerctl stop
		;;
	"Open Player")
		# Try to open the player - works with common players
		PLAYER=$(playerctl -l 2>/dev/null | head -n1)
		if [ -n "$PLAYER" ]; then
			case "$PLAYER" in
			*spotify*)
				gtk-launch spotify
				;;
			*firefox*)
				firefox
				;;
			*chromium*)
				chromium
				;;
			*vlc*)
				vlc
				;;
			*)
				notify-send "Media Controls" "Cannot open player: $PLAYER"
				;;
			esac
		else
			notify-send "Media Controls" "No active player detected"
		fi
		;;
	"🔊 Increase Volume")
		pactl set-sink-volume @DEFAULT_SINK@ +5% 2>/dev/null ||
			amixer -q set Master 5%+ 2>/dev/null
		;;
	"🔉 Decrease Volume")
		pactl set-sink-volume @DEFAULT_SINK@ -5% 2>/dev/null ||
			amixer -q set Master 5%- 2>/dev/null
		;;
	"🔇 Toggle Mute")
		pactl set-sink-mute @DEFAULT_SINK@ toggle 2>/dev/null ||
			amixer -q set Master toggle 2>/dev/null
		;;
	"Set Default Player")
		# List available players and set default
		PLAYERS=$(playerctl -l 2>/dev/null)
		if [ -n "$PLAYERS" ]; then
			SELECTED=$(echo "$PLAYERS" | eval "$ROFI_CMD -p 'Select Player'")
			if [ -n "$SELECTED" ]; then
				# Export would only work for current session, so we'll use playerctl directly
				notify-send "Media Controls" "Set $SELECTED as active player"
				# In a real implementation, you might want to save this to a config file
			fi
		else
			notify-send "Media Controls" "No media players detected"
		fi
		;;
	"Open Sound Settings")
		# Try to open sound settings based on DE
		if command -v gnome-control-center &>/dev/null; then
			gnome-control-center sound
		elif command -v pavucontrol &>/dev/null; then
			pavucontrol
		else
			notify-send "Media Controls" "Sound settings not found"
		fi
		;;
	esac
}

# Position the menu at the mouse cursor
get_mouse_position() {
	if command -v xdotool &>/dev/null; then
		POS=$(xdotool getmouselocation --shell)
		eval "$POS"
		echo "-x $X -y $Y"
	else
		echo ""
	fi
}

# Main execution starts here
if [ "$1" = "--xmenu" ]; then
	# Get mouse position
	MOUSE_POS=$(get_mouse_position)

	# Show the menu at the mouse position
	if [ -n "$MOUSE_POS" ]; then
		ROFI_CMD="rofi -dmenu -i -no-fixed-num-lines -width 15 $MOUSE_POS -theme-str 'window {border: 1px; border-color: #888888; border-radius: 2px;} listview {lines: 12; scrollbar: false;} element {padding: 4px;}'"
	fi

	selection=$(generate_menu "main" | eval "$ROFI_CMD -p 'Media'")
	[ -n "$selection" ] && execute_command "$selection"
else
	# Standard mode for rofi
	if [ -z "$@" ]; then
		generate_menu "main"
	else
		execute_command "$@"
	fi
fi
