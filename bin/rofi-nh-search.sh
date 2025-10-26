#!/usr/bin/env bash

set -euo pipefail

# Ensure required commands are available
for cmd in nh rofi xdg-open; do
  command -v "$cmd" >/dev/null || {
    echo "❌ Missing required command: $cmd"
    exit 1
  }
done

# Prompt for search query
query="$(rofi -dmenu -p "Search nixpkgs (nh)" -lines 0)"
[ -z "$query" ] && exit 0

# Perform search using nh
results=$(nh search "$query" | grep -E '^•' | sed 's/^• //' || true)

[ -z "$results" ] && {
  rofi -e "No results for '$query'"
  exit 1
}

# Prompt user to select package
choice=$(echo "$results" | rofi -dmenu -p "View package info")

[ -z "$choice" ] && exit 0

# Extract attribute name (everything before the first space)
attr_name=$(echo "$choice" | awk '{print $1}')

# Construct search.nixos.org URL for unstable channel
url="https://search.nixos.org/packages?channel=unstable&show=$attr_name"

# Open in browser
xdg-open "$url" >/dev/null 2>&1 &
