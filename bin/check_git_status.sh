#!/usr/bin/env bash
# Usage: ./check_git_status.sh /path/to/directory
# Checks if the given directory has unstaged git changes and sends a notification.

DIRECTORY="$1"

if [[ -z $DIRECTORY ]]; then
	echo "Error: No directory provided."
	exit 1
fi

if [[ ! -d "$DIRECTORY/.git" ]]; then
	echo "Error: The provided directory is not a Git repository."
	exit 1
fi

# Check for unstaged changes
cd "$DIRECTORY" || exit
if [[ -n $(git status --porcelain) ]]; then
	notify-send "Git Alert" "Unstaged changes in $DIRECTORY"
else
	notify-send "Git Status" "No unstaged changes in $DIRECTORY"
fi
