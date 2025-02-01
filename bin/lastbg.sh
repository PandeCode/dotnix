#!/usr/bin/env bash

source $DOTFILES/bin/bg.sh
new_img=$(tail -n 2 $img_log_file | sed '2d')
setbg $new_img
