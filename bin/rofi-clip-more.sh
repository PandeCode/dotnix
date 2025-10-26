#!/usr/bin/env bash

cliphist list | rofi -dmenu | cliphist decode | xargs -I '{}' ydotool type '{}'
