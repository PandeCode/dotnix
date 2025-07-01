#!/usr/bin/env bash
# gif-to-atlas.sh — Convert an animated GIF into a horizontal texture atlas

set -euo pipefail

if [[ $# -lt 2 ]]; then
	echo "Usage: $0 input.gif output.png"
	exit 1
fi

INPUT_GIF="$1"
OUTPUT_ATLAS="$2"

# Create a temporary directory
TMPDIR=$(mktemp -d)

# Extract all frames
convert "$INPUT_GIF" "$TMPDIR/frame.png"

# Concatenate frames horizontally into a texture atlas
montage "$TMPDIR"/frame*.png -tile x1 -geometry +0+0 "$OUTPUT_ATLAS"

# Clean up
rm -r "$TMPDIR"

echo "Texture atlas saved to: $OUTPUT_ATLAS"
