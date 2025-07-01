#!/usr/bin/env bash
#!/bin/bash

# Interval (in seconds) between updates
UPDATE_INTERVAL=3

# Temp file to store selection
SELECTION_FILE=$(mktemp)

# Function to get process list
get_process_list() {
	ps -eo pid,etime,%mem,%cpu,comm --sort=-%mem,-%cpu |
		awk 'NR==1 {printf "%-6s %-10s %-6s %-6s %-20s\n", $1, $2, $3, $4, $5}
         NR>1 {printf "%-6s %-10s %-6s %-6s %-20s\n", $1, $2, $3, $4, $5}'
}

# Function to run rofi with current process list
run_rofi() {
	get_process_list | rofi -dmenu -i -p "Kill Process" -multi-select >"$SELECTION_FILE"
}

# Main loop: display rofi and kill selected processes
while true; do
	run_rofi
	if [[ -s "$SELECTION_FILE" ]]; then
		# Extract PID(s) from selected lines (1st column)
		PIDS=$(awk '{print $1}' "$SELECTION_FILE")
		echo "$PIDS" | xargs -r kill -9
		echo "Killed: $PIDS"
		break
	fi
	sleep "$UPDATE_INTERVAL"
done

# Cleanup
rm "$SELECTION_FILE"
