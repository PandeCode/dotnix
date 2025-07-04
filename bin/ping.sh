#!/usr/bin/env bash

RED=#ff5555
GREEN=#50fa7b
YELLOW=#f1fa8c
WHITE=#f8f8f2
NO_NET="󰪎"
BEST_NET="󰀳"
OK_NET="󰖟"
BAD_NET="󱂠"
PING_HOST=$ZELLIJ_PING_HOST

is_number() {
	[[ $1 =~ ^[0-9]+$ ]]
}

min() {
	echo $(($1 > $2 ? $2 : $1))
}

ping_host="$PING_HOST"
if [ -z "$ping_host" ]; then ping_host="9.9.9.9"; fi

ping_count=3
ping_wait_time=255

ping_log_file="/tmp/ping.log"
ping_result_file="/tmp/ping_result"
ping_pid_file="/tmp/ping.pid"

ping_not_running() {
	local pid
	pid=$(cat $ping_pid_file)
	! ps -p "$pid" >/dev/null
}

read_cached_result() {
	if [ -e $ping_result_file ]; then
		cat $ping_result_file
	else
		echo -1
	fi
}

read_ping_result() {
	result=$(cut -sd / -f 5 $ping_log_file | cut -d . -f 1)

	if is_number "$result"; then
		echo "$result"
	else
		echo -1
	fi
}

update_cached_result() {
	echo "$1" >$ping_result_file
}

execute_ping() {
	ping -c $ping_count -t $ping_wait_time "$ping_host" 2>/dev/null >$ping_log_file &
	echo "$!" >$ping_pid_file
}

colorize_ping_value() {
	local ping=$1
	local result

	if [ "$ping" -lt 1 ] || [ "$ping" -ge 1000 ]; then
		result=$RED
	elif [ "$ping" -lt 100 ]; then
		result=$GREEN
	elif [ "$ping" -lt 400 ]; then
		result=$WHITE
	elif [ "$ping" -lt 1000 ]; then
		result=$YELLOW
	fi

	echo "$result"
}

ping_icon() {
	local ping=$1
	local result

	if [ "$ping" -lt 1 ] || [ "$ping" -ge 1000 ]; then
		result="$NO_NET"
	elif [ "$ping" -lt 100 ]; then
		result="$BEST_NET"
	elif [ "$ping" -lt 400 ]; then
		result="$OK_NET"
	elif [ "$ping" -lt 1000 ]; then
		result="$BAD_NET"
	fi

	echo $result
}

format_ping_value() {
	local value=$1
	local result

	if [ "$value" -eq -1 ]; then
		result="N/A"
	elif [ "$value" -ge 1000 ]; then
		result=$(min "$value" 9999)
		result=$((result / 1000))
		result=">$result"K
	else
		result=$(printf %3d "$value")
	fi

	echo "$result"
}

addPadding() {
	if [ "$1" -gt 100 ]; then
		echo ""
	else
		echo " "
	fi
}

icon=${1:no}

main() {
	local ping_result

	if ping_not_running; then
		ping_result=$(read_ping_result)
		update_cached_result "$ping_result"

		execute_ping

	else
		ping_result=$(read_cached_result)
	fi

	ping_value=$ping_result
	ping_result="$(format_ping_value "$ping_result")"

	if [[ "$icon" == "no" ]]; then
		echo -n "$(colorize_ping_value "$ping_value") ${ping_result}"
	else
		echo -n "$(colorize_ping_value "$ping_value") $(ping_icon "$ping_value") ${ping_result}"
	fi
}

main
