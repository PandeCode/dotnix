#!/usr/bin/env bash
source $DOTFILES/bin/bg.sh

new_img=$(find $img_dir -type f | shuf -n 1)
setbg $new_img
