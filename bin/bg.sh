#!/usr/bin/env bash

# =========================================================
# Wallpaper Management Script
#
# Handles wallpaper setting for both X11 and Wayland sessions
# with support for various transformations and effects.
# =========================================================

# Configuration variables
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wallpaper-manager"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-manager"
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper-manager"
CONVERTED_DIR="$CACHE_DIR/converted"

# Create required directories
mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$LOG_DIR" "$CONVERTED_DIR"

# File paths
IMG_LOG_FILE="$LOG_DIR/wallpaper-history.log"
IMG_DIR="${WALLPAPER_DIR:-$HOME/Pictures/walls/walls-main/anime}"
IMG_INDEX_FILE="$CACHE_DIR/wallpaper-index.txt"
BG_ID_FILE="$CACHE_DIR/current-bg-id"

# =========================================================
# Helper Functions
# =========================================================

notify() {
	if [ -n "${SILENT}" ]; then
		echo "$@" >&2
	else
		notify-send "$@"
	fi
}

# Log messages to stderr and optionally to a file
log() {
	local level="$1"
	local message="$2"
	local log_to_file="${3:-false}"

	echo "[$level] $message" >&2

	if [[ "$log_to_file" == "true" ]]; then
		echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >>"$LOG_DIR/debug.log"
	fi
}

# Check if a file exists and is readable
check_file() {
	if [[ ! -f "$1" || ! -r "$1" ]]; then
		log "ERROR" "File does not exist or is not readable: $1" true
		return 1
	fi
	return 0
}

# Check if a directory exists and is readable
check_directory() {
	if [[ ! -d "$1" || ! -r "$1" ]]; then
		log "ERROR" "Directory does not exist or is not readable: $1" true
		return 1
	fi
	return 0
}

# Convert MP4 to GIF if needed
convert_if_mp4() {
	local input_file="$1"
	local file_ext="${input_file##*.}"

	# Check if it's an MP4 file
	if [[ "${file_ext,,}" == "mp4" ]]; then
		# Check if ffmpeg is installed
		if ! command -v ffmpeg &>/dev/null; then
			log "ERROR" "ffmpeg is not installed, cannot convert MP4 to GIF" true
			return 1
		fi

		local output_file="$CONVERTED_DIR/$(basename "${input_file%.*}").gif"

		# Check if converted file already exists and is newer than the source
		if [[ -f "$output_file" && "$output_file" -nt "$input_file" ]]; then
			log "INFO" "Using existing converted GIF: $output_file" true
			echo "$output_file"
			return 0
		fi

		log "INFO" "Converting MP4 to GIF: $input_file" true

		# Convert MP4 to GIF using ffmpeg
		ffmpeg -i "$input_file" -vf "fps=10,scale=480:-1:flags=lanczos" -c:v gif "$output_file" >/dev/null
		# ffmpeg -i "$input_file" "$output_file" >/dev/null 2>&1

		if [[ $? -eq 0 ]]; then
			log "INFO" "Successfully converted to GIF: $output_file" true
			echo "$output_file"
			return 0
		else
			log "ERROR" "Failed to convert MP4 to GIF" true
			return 1
		fi
	else
		# Not an MP4, return the original file
		echo "$input_file"
	fi
}

# Initialize the environment
initialize() {
	# Create log file if it doesn't exist
	touch "$IMG_LOG_FILE"

	# Remove empty lines from log file
	sed -i '/^$/d' "$IMG_LOG_FILE"

	# Read background ID if available
	if [[ -f "$BG_ID_FILE" ]]; then
		BG_ID="$(cat "$BG_ID_FILE")"
	else
		BG_ID=""
	fi

	# Create image index if not exists or if it's outdated
	if [[ ! -f "$IMG_INDEX_FILE" || "$(find "$IMG_DIR" -type f -newer "$IMG_INDEX_FILE" | wc -l)" -gt 0 ]]; then
		if check_directory "$IMG_DIR"; then
			find "$IMG_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.mp4" \) -print >"$IMG_INDEX_FILE"
			log "INFO" "Generated wallpaper index with $(wc -l <"$IMG_INDEX_FILE") files" true
		else
			log "ERROR" "Failed to create wallpaper index: image directory not accessible" true
			exit 1
		fi
	fi
}

# Apply transformations to the wallpaper if requested
apply_transformations() {
	local img="$1"
	local transformations=""

	# Only process if the gowall command exists
	if ! command -v gowall &>/dev/null; then
		echo "$transformations:$img"
		return
	fi

	# Apply gowall theme if specified
	if [[ -n "${GO_WALL}" ]]; then
		gowall convert "$img" -t "${GO_WALL:-nix}" >&2
		transformations+=" $GO_WALL"
		img="$HOME/Pictures/gowall/$(basename "$img")"
	fi

	# Apply inversion if specified
	if [[ -n "${GO_WALL_INVERT}" ]]; then
		gowall invert "$img" >&2
		transformations+=" inverted"
		img="$HOME/Pictures/gowall/$(basename "$img")"
	fi

	# Apply pixelation if specified
	if [[ -n "${GO_WALL_PIXELATE}" ]]; then
		gowall pixelate "$img" -s "$GO_WALL_PIXELATE" >&2
		transformations+=" pixelated($GO_WALL_PIXELATE)"
		img="$HOME/Pictures/gowall/$(basename "$img")"
	fi

	if [[ -n "${GO_WALL_EFFECT}" ]]; then
		IFS='|' read -ra effects <<<"$GO_WALL_EFFECT"
		for effect in "${effects[@]}"; do
			gowall $effect "$img" >&2
			transformations+=" effect($effect)"
			img="$HOME/Pictures/gowall/$(basename "$img")"
		done
	fi

	echo "$transformations:$img"
}

# Process an image and either set it as wallpaper or output info
process_wallpaper() {
	local img="$1"
	local original_img="$1"
	local get_only="${2:-false}"
	local transformation_result=""

	# Convert MP4 to GIF if needed
	img=$(convert_if_mp4 "$img")
	if [[ $? -ne 0 ]]; then
		return 1
	fi

	# Apply any transformations
	transformation_result=$(apply_transformations "$img")
	if [[ "$transformation_result" == *":"* ]]; then
		local transformations="${transformation_result%%:*}"
		img="${transformation_result#*:}"
	else
		local transformations=""
	fi

	# Check if image exists
	if ! check_file "$img"; then
		notify "Wallpaper Error" "Image file does not exist: $img" --urgency=critical
		return 1
	fi

	# If get_only is true, just output the image and transformations
	if [[ "$get_only" == "true" ]]; then
		echo "$img"
		return 0
	fi

	# Set wallpaper based on session type
	case "$XDG_SESSION_TYPE" in
	"x11")
		if command -v feh &>/dev/null; then
			feh --bg-fill "$img"
			log "INFO" "Set wallpaper (X11/feh): $img" true
		else
			notify "Wallpaper Error" "feh is not installed" --urgency=critical
			return 1
		fi
		;;

	"wayland")
		# Handle different Wayland wallpaper managers
		if pgrep -x "hyprpaper" &>/dev/null; then
			hyprctl hyprpaper preload "$img"
			hyprctl hyprpaper wallpaper "eDP-1,$img"
			log "INFO" "Set wallpaper (Wayland/hyprpaper): $img" true
		elif pgrep -x "swww-daemon" &>/dev/null; then
			swww img "$img" --transition-type wipe >/dev/null 2>&1
			log "INFO" "Set wallpaper (Wayland/swww): $img" true
		elif pgrep -x "swaybg" &>/dev/null; then
			killall -9 swaybg >/dev/null 2>&1
			swaybg -i "$img" -m fill >/dev/null 2>&1 &
			disown
			log "INFO" "Set wallpaper (Wayland/swaybg): $img" true
		else
			notify "Wallpaper Error" "No supported Wayland wallpaper manager found" --urgency=critical
			return 1
		fi
		;;

	*)
		notify "Wallpaper Error" "Unsupported session type: $XDG_SESSION_TYPE" --urgency=critical
		log "ERROR" "Unsupported session type: $XDG_SESSION_TYPE" true
		return 1
		;;
	esac

	# Update logs and notify user
	echo "$original_img" >>"$IMG_LOG_FILE"

	# Send notification with proper replacement
	if [[ -n "$BG_ID" ]]; then
		BG_ID=$(notify "Wallpaper Changed" "${transformations:+[$transformations] }$(basename "$img")" --icon "$img" --replace-id="$BG_ID" --print-id)
	else
		BG_ID=$(notify "Wallpaper Changed" "${transformations:+[$transformations] }$(basename "$img")" --icon "$img" --print-id)
	fi

	# Save notification ID for future replacements
	echo "$BG_ID" >"$BG_ID_FILE"

	return 0
}

# Get the last wallpaper from history
get_last_wallpaper() {
	if [[ -s "$IMG_LOG_FILE" ]]; then
		tail -n 1 "$IMG_LOG_FILE"
	else
		log "ERROR" "No wallpaper history found" true
		return 1
	fi
}

# Get the second-to-last wallpaper from history
get_previous_wallpaper() {
	if [[ $(wc -l <"$IMG_LOG_FILE") -ge 2 ]]; then
		tail -n 2 "$IMG_LOG_FILE" | head -n 1
	else
		log "ERROR" "No previous wallpaper in history" true
		return 1
	fi
}

# Get the next wallpaper from the index
get_next_wallpaper() {
	local last_img=$(get_last_wallpaper)
	local found_last=false
	local next_img=""

	while IFS= read -r line; do
		if [[ "$found_last" == "true" ]]; then
			next_img="$line"
			break
		fi

		if [[ "$line" == "$last_img" ]]; then
			found_last=true
		fi
	done <"$IMG_INDEX_FILE"

	# If we reached the end of the list, loop to the beginning
	if [[ -z "$next_img" ]]; then
		next_img=$(head -n 1 "$IMG_INDEX_FILE")
	fi

	echo "$next_img"
}

# Get the previous wallpaper from the index
get_prev_wallpaper() {
	local last_img=$(get_last_wallpaper)
	local prev_img=""
	local current_img=""

	while IFS= read -r line; do
		if [[ "$line" == "$last_img" ]]; then
			# If prev_img is empty, we're at the beginning of the list
			if [[ -z "$prev_img" ]]; then
				# Get the last line of the index for wrap-around
				prev_img=$(tail -n 1 "$IMG_INDEX_FILE")
			fi
			break
		fi
		prev_img="$current_img"
		current_img="$line"
	done <"$IMG_INDEX_FILE"

	echo "$prev_img"
}

# Get a random wallpaper
get_random_wallpaper() {
	if check_directory "$IMG_DIR"; then
		find "$IMG_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.mp4" \) | shuf -n 1
	else
		return 1
	fi
}

# =========================================================
# Main Functions
# =========================================================

# Set or get the last used wallpaper
handle_last_wallpaper() {
	local get_only="${1:-false}"
	local last_img=$(get_last_wallpaper)
	if [[ -n "$last_img" ]]; then
		process_wallpaper "$last_img" "$get_only"
	fi
}

# Set or get the previous wallpaper from history
handle_previous_wallpaper() {
	local get_only="${1:-false}"
	local prev_img=$(get_previous_wallpaper)
	if [[ -n "$prev_img" ]]; then
		process_wallpaper "$prev_img" "$get_only"
	fi
}

# Set or get the next wallpaper from the index
handle_next_wallpaper() {
	local get_only="${1:-false}"
	local next_img=$(get_next_wallpaper)
	if [[ -n "$next_img" ]]; then
		process_wallpaper "$next_img" "$get_only"
	fi
}

# Set or get the previous wallpaper from the index
handle_prev_wallpaper() {
	local get_only="${1:-false}"
	local prev_img=$(get_prev_wallpaper)
	if [[ -n "$prev_img" ]]; then
		process_wallpaper "$prev_img" "$get_only"
	fi
}

# Set or get a random wallpaper
handle_random_wallpaper() {
	local get_only="${1:-false}"
	local random_img=$(get_random_wallpaper)
	if [[ -n "$random_img" ]]; then
		process_wallpaper "$random_img" "$get_only"
	fi
}

# Set a specific image as wallpaper
handle_set_image() {
	local image_path="$1"
	local get_only="${2:-false}"
	image_path="$(realpath "$image_path")"

	if [[ -n "$image_path" ]]; then
		process_wallpaper "$image_path" "$get_only"
	else
		log "ERROR" "No image path provided" true
		return 1
	fi
}

# Show usage information
show_usage() {
	cat <<EOF >&2
Wallpaper Management Script

Usage:
  $(basename "$0") [COMMAND]

Commands:
  last            - Set the last used wallpaper
  get-last        - Output the path of the last used wallpaper
  prev            - Set the previous wallpaper in the index
  get-prev        - Output the path of the previous wallpaper in the index
  next            - Set the next wallpaper in the index
  get-next        - Output the path of the next wallpaper in the index
  random          - Set a random wallpaper
  get-random      - Output the path of a random wallpaper
  reset           - Reset to the current wallpaper
  get-reset       - Output the path of the current wallpaper
  set IMAGE_PATH  - Set a specific image as wallpaper
  get-set IMAGE_PATH - Output the path of a specific image with transformations
  help            - Show this help message

Environment Variables:
  WALLPAPER_DIR      - Directory containing wallpapers (default: ~/Pictures/walls)
  GO_WALL            - Theme for gowall transformation
  GO_WALL_INVERT     - Enable inversion (any non-empty value)
  GO_WALL_PIXELATE   - Pixelation scale
  GO_WALL_EFFECT     - Special effect to apply

Notes:
  - MP4 files are automatically converted to GIF format using ffmpeg (if installed)
  - Converted files are stored in: $CONVERTED_DIR

EOF
}

# =========================================================
# Main Script
# =========================================================

# Initialize environment
initialize

case "$1" in
"lastbg" | "last")
	handle_last_wallpaper false
	;;
"get-lastbg" | "get-last")
	handle_last_wallpaper true
	;;
"nextbg" | "next")
	handle_next_wallpaper false
	;;
"get-nextbg" | "get-next")
	handle_next_wallpaper true
	;;
"prevbg" | "prev")
	handle_prev_wallpaper false
	;;
"get-prevbg" | "get-prev")
	handle_prev_wallpaper true
	;;
"randbg" | "random" | "rand")
	handle_random_wallpaper false
	;;
"get-randbg" | "get-random" | "get-rand")
	handle_random_wallpaper true
	;;
"resetbg" | "reset")
	handle_last_wallpaper false
	;;
"get-resetbg" | "get-reset")
	handle_last_wallpaper true
	;;
"set")
	if [[ -z "$2" ]]; then
		log "ERROR" "No image path provided for set command" true
		show_usage
		exit 1
	fi
	handle_set_image "$2" false
	;;
"get-set")
	if [[ -z "$2" ]]; then
		log "ERROR" "No image path provided for get-set command" true
		show_usage
		exit 1
	fi
	handle_set_image "$2" true
	;;
"help" | "-h" | "--help")
	show_usage
	;;
*)
	log "ERROR" "Unknown command: $1" true
	show_usage
	exit 1
	;;
esac

exit $?
