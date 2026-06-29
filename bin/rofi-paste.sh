#!/usr/bin/env bash

notify-send "fix for x"

cliphist list | rofi -dmenu | cliphist decode | xargs -I '{}' ydotool type '{}'
