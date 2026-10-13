#!/usr/bin/env bash
# rofi-clip-more.sh: types a clipboard history entry into the focused window

cliphist list | rofi -dmenu | cliphist decode | ydotool type --file -
