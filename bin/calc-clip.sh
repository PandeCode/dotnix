#!/usr/bin/env bash

convert_scientific() {
	sed -E 's/([0-9]+(\.[0-9]+)?)e([+-]?[0-9]+)/\1 * 10^{\3}/g'
}

braces_to_parens() {
	sed 's/{/(/g; s/}/)/g'
}

parens_to_braces() {
	sed 's/(/{/g; s/)/}/g'
}

text=$(wl-paste | tr -d '\n' | braces_to_parens)
output=$(numbat -e "$text" | tr -d '\n' | convert_scientific)

notify-send "Clip Calc" "$text\n\n$output"

# echo "$output" | xargs -I '{}' ydotool type '{}'
echo "$output" | wl-copy
