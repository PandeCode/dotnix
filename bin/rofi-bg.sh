#!/usr/bin/env bash
# rofi-bg.sh: rofi menu over wall

OPTIONS=(
	"last"
	"random"
	"prev"
	"next"
	"reset"
	"set"
)

USE_NIX=$(printf "no\nyes" | rofi -dmenu -i -p "Use GO_WALL=nix?")
[[ -z $USE_NIX ]] && exit
[[ $USE_NIX == "yes" ]] && export GO_WALL=nix

while true; do
	CHOSEN=$(printf "%s\n" "${OPTIONS[@]}" | rofi -dmenu -i -p "Wallpaper Action")

	[[ -z $CHOSEN ]] && break

	if [[ $CHOSEN == "set" ]]; then
		IMAGE_PATH=$(rofi -dmenu -p "Enter image path")
		[[ -z $IMAGE_PATH ]] && continue
		wall set "${IMAGE_PATH/#\~/$HOME}"
	else
		wall "$CHOSEN"
	fi
done
