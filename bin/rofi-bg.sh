#!/usr/bin/env bash

BG_SCRIPT="bg.sh"

OPTIONS=(
	"last"
	"prev"
	"next"
	"random"
	"reset"
	"set"
)

USE_NIX=$(printf "no\nyes" | rofi -dmenu -i -p "Use GO_WALL=nix?")
[[ -z "$USE_NIX" ]] && exit

CMD_PREFIX=""
[[ "$USE_NIX" == "yes" ]] && CMD_PREFIX="GO_WALL=nix"

while true; do
	CHOSEN=$(printf "%s\n" "${OPTIONS[@]}" | rofi -dmenu -i -p "Wallpaper Action")

	[[ -z "$CHOSEN" ]] && break

	if [[ "$CHOSEN" == "set" ]]; then
		IMAGE_PATH=$(rofi -dmenu -p "Enter image path")
		[[ -z "$IMAGE_PATH" ]] && continue
		eval $CMD_PREFIX "$BG_SCRIPT" "$CHOSEN" "\"$IMAGE_PATH\""
	else
		eval $CMD_PREFIX "$BG_SCRIPT" "$CHOSEN"
	fi
done
