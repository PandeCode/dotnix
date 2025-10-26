#!/usr/bin/env bash

min_ws=1
max_ws=9

get_current_ws() {
	i3-msg -t get_workspaces | jq '.[] | select(.focused==true) | .num'
}

get_occupied_workspaces() {
	i3-msg -t get_workspaces | jq '[.[] | select(.windows > 0) | .num]'
}

find_next_occupied_ws() {
	local current_ws=$1
	local direction=$2
	local occupied=$3
	local ws=$current_ws

	while :; do
		((ws += direction))
		if ((ws < min_ws || ws > max_ws)); then
			break
		fi
		if echo "$occupied" | jq --argjson id "$ws" 'index($id)' | grep -qv null; then
			echo "$ws"
			return
		fi
	done
	echo ""
}

smart_workspace_nav() {
	local direction=$1
	local current_ws
	current_ws=$(get_current_ws)
	local occupied_workspaces
	occupied_workspaces=$(get_occupied_workspaces)
	local next_ws
	next_ws=$(find_next_occupied_ws "$current_ws" "$direction" "$occupied_workspaces")

	if [[ -n "$next_ws" ]]; then
		i3-msg workspace "$next_ws"
	else
		fallback_ws=$((current_ws + direction))
		if ((fallback_ws >= min_ws && fallback_ws <= max_ws)); then
			i3-msg workspace "$fallback_ws"
		fi
	fi
}

move_window_basic() {
	local direction=$1
	local current_ws
	current_ws=$(get_current_ws)
	local target_ws=$((current_ws + direction))

	if ((target_ws >= min_ws && target_ws <= max_ws)); then
		i3-msg move container to workspace "$target_ws"
	fi
}

# Focus with fallback to workspace navigation
focus_or_switch_ws() {
	local dir=$1

	# Try to focus in the given direction
	if i3-msg focus "$dir" 2>/dev/null | jq -r '.success' | grep -q false; then
		# If focus failed, switch workspace
		case "$dir" in
		left) smart_workspace_nav -1 ;;
		right) smart_workspace_nav 1 ;;
		up) smart_workspace_nav -1 ;;
		down) smart_workspace_nav 1 ;;
		esac
	fi
}

move_window() {
	local dir=$1
	case "$dir" in
	left|right|up|down) i3-msg move "$dir" ;;
	esac
}

resize_window() {
	local dir=$1
	local amount=10 # i3 uses percentage or pixels

	case "$dir" in
	left) i3-msg resize shrink width "$amount" px or "$amount" ppt ;;
	right) i3-msg resize grow width "$amount" px or "$amount" ppt ;;
	up) i3-msg resize shrink height "$amount" px or "$amount" ppt ;;
	down) i3-msg resize grow height "$amount" px or "$amount" ppt ;;
	esac
}

case "$1" in
focus_l) focus_or_switch_ws left ;;
focus_r) focus_or_switch_ws right ;;
focus_u) smart_workspace_nav -1 ;;
focus_d) smart_workspace_nav 1 ;;
move_l) move_window left ;;
move_r) move_window right ;;
move_u) move_window_basic -1 ;;
move_d) move_window_basic 1 ;;
resize_l) resize_window left ;;
resize_r) resize_window right ;;
resize_u) resize_window up ;;
resize_d) resize_window down ;;
*)
	echo "Usage: $0 {focus_{l|r|u|d}|move_{l|r|u|d}|resize_{l|r|u|d}}"
	exit 1
	;;
esac
