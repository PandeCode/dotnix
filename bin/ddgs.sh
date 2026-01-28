#!/usr/bin/env bash

hash_dir=~/.cache/ddgs

mkdir -p $hash_dir

hash() {
	echo -n "$1" | md5sum | awk '{print $1}'
}

get_list() {
	param="$1"
	file=$hash_dir/$(hash "$param")

	if [ -f "$file" ]; then
		cat "$file"
	else
		data=$(curl "https://duckduckgo.com/ac/?q=$param" -s | jq -r '.[] .phrase')
		echo -n "$data" > "$file"
		echo -n "$data"
	fi
}

get_list $1
