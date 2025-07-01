#!/usr/bin/env bash

# Get the list of home-manager generations
generations=($(home-manager generations | awk '{print $7}'))

# Validate argument
if [[ "$1" != "dark" && "$1" != "light" ]]; then
	echo "Usage: $0 <dark|light>"
	exit 1
fi
choice="$1"

# Iterate through all available generations
for gen in "${generations[@]}"; do
	if [[ -d "$gen/specialisation/$choice" ]]; then
		echo "Activating $choice specialisation from generation: $gen"
		bash -c "$gen/specialisation/$choice/activate"
		exit 0
	fi
done

echo "No valid $choice specialisation directory found in any generation."
