#!/usr/bin/env bash

# Define the source and destination file paths
SOURCE_FILE="$HOME/.config/waybar/config"
DEST_FILE="$HOME/.config/waybar/niri.json"

rm -fr "$DEST_FILE"
# Copy the source file to the destination file
cp "$SOURCE_FILE" "$DEST_FILE"

# Replace every occurrence of 'hyprland' with 'niri' in the destination file
sed -i 's/hyprland/niri/g' "$DEST_FILE"

# Return the absolute file name of the destination file
echo "$DEST_FILE"
