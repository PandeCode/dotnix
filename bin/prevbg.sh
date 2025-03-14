#!/usr/bin/env bash

source "$DOTFILES/bin/bg.sh"

last_img=$(tail -n 1 $img_log_file)

new_img=''
pre_img=''
while read line; do
	if [ "$line" == "$last_img" ]; then
		new_img=$pre_img
		break
	fi

	pre_img=$line
done <<<$(cat $img_file_index)

setbg $new_img
