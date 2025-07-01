#!/usr/bin/env bash

min_ws=1
max_ws=9

get_current_ws() {
	hyprctl activeworkspace -j | jq '.id'
}

get_occupied_workspaces() {
	hyprctl workspaces -j | jq '[.[] | select(.windows > 0) | .id]'
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
		hyprctl dispatch workspace "$next_ws"
	else
		fallback_ws=$((current_ws + direction))
		if ((fallback_ws >= min_ws && fallback_ws <= max_ws)); then
			hyprctl dispatch workspace "$fallback_ws"
		fi
	fi
}

move_window_basic() {
	local direction=$1
	local current_ws
	current_ws=$(get_current_ws)

	local target_ws=$((current_ws + direction))
	if ((target_ws >= min_ws && target_ws <= max_ws)); then
		hyprctl dispatch movetoworkspace "$target_ws"
	fi
}

# Focus with fallback to workspace navigation
focus_or_switch_ws() {
	local dir=$1
	if ! hyprctl dispatch movefocus "$dir"; then
		case "$dir" in
		l) smart_workspace_nav -1 ;;
		r) smart_workspace_nav 1 ;;
		u) smart_workspace_nav -1 ;; # Optional: treat u/d like l/r
		d) smart_workspace_nav 1 ;;
		esac
	fi
}

move_window() {
	local dir=$1

	case "$dir" in
	l | r) hyprctl dispatch layoutmsg movewindowto "$dir" ;;
	u | d) hyprctl dispatch imovewindow "$dir" ;;
	esac

}

resize_window() {
	local dir=$1
	local amount=50 # Adjust if needed

	case "$dir" in
	l) hyprctl dispatch resizeactive -$amount 0 ;;
	r) hyprctl dispatch resizeactive $amount 0 ;;
	u) hyprctl dispatch resizeactive 0 -$amount ;;
	d) hyprctl dispatch resizeactive 0 $amount ;;
	esac
}

case "$1" in

focus_l) focus_or_switch_ws l ;;
focus_r) focus_or_switch_ws r ;;

focus_u) smart_workspace_nav -1 ;;
focus_d) smart_workspace_nav 1 ;;

move_l) move_window l ;;
move_r) move_window r ;;

move_u) move_window_basic -1 ;;
move_d) move_window_basic 1 ;;

resize_l) resize_window l ;;
resize_r) resize_window r ;;
resize_u) resize_window u ;;
resize_d) resize_window d ;;

*)
	echo "Usage: $0 {ws_up|ws_down|mv_up|mv_down|focus_{l|r|u|d}|move_{l|r|u|d}|resize_{l|r|u|d}}"
	exit 1
	;;
esac
