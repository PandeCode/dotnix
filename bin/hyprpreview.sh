#!/usr/bin/env bash
line="$1"

IFS=$'\t' read -r addr _ <<<"$line"
dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}

grim -t png -l 0 -w "$addr" /tmp/preview.png
chafa --animate false -s "$dim" "/tmp/preview.png"
