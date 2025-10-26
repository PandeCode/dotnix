#!/usr/bin/env bash

(
	[[ -f $1 ]] &&
		(
			bat --color=always --style=numbers --line-range=:500 "$1" ||
				cat "$1"
		)
) ||
	(
		[[ -d $1 ]] &&
			(
				tree "$1" | less
			)
	) ||
	echo "$1" 2>/dev/null | head -200
