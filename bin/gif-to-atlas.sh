#!/usr/bin/env bash
# gif-to-atlas.sh: convert an animated GIF into a horizontal texture atlas

set -euo pipefail

if [[ $# -lt 2 ]]; then
	echo "Usage: $0 input.gif output.png"
	exit 1
fi

INPUT_GIF="$1"
OUTPUT_ATLAS="$2"

# coalesce turns optimized frames back into full ones
magick "$INPUT_GIF" -coalesce +append "$OUTPUT_ATLAS"

echo "Texture atlas saved to: $OUTPUT_ATLAS"
