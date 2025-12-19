#!/usr/bin/env bash

UPDATE_INTERVAL=3
SELECTION_FILE=$(mktemp)

get_process_list() {
	ps -eo pid,etime,%mem,%cpu,comm --sort=-%mem,-%cpu |
		awk 'NR==1 {printf "%-6s %-10s %-6s %-6s %-20s\n", $1, $2, $3, $4, $5}
	NR>1 {printf "%-6s %-10s %-6s %-6s %-20s\n", $1, $2, $3, $4, $5}'
}
run_rofi() {
	get_process_list | rofi -dmenu -i -p "Kill Process" -multi-select >"$SELECTION_FILE"
}

run_rofi
if [[ -s "$SELECTION_FILE" ]]; then
	PIDS=$(awk '{print $1}' "$SELECTION_FILE")
	echo "$PIDS" | xargs -r kill -9
	echo "Killed: $PIDS"
	break
fi

rm "$SELECTION_FILE"
