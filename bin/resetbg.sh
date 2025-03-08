#!/usr/bin/env bash

source "$DOTFILES/bin/bg.sh"
new_img=$(tail -n 1 $img_log_file)
setbg "$new_img"
