#!/usr/bin/env bash

source $DOTFILES/bin/bg.sh
last_img=$(tail -n 1 $img_log_file)

found_last_img=false
new_img=''
while read line; do
	if [ "$line" == "$last_img" ]; then
		found_last_img=true
	elif $found_last_img; then
		new_img="$line"
		break
	fi
done <<<$(cat $img_file_index)

setbg $new_img
