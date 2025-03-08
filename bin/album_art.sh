#!/usr/bin/env bash

album_art=$(playerctl -p spotify metadata mpris:artUrl)

set() {
	echo "$1"
	cp "$1" /tmp/cover.jpg
}

if [[ -z $album_art ]]; then
	album_art=$(playerctl -p spotify_player metadata mpris:artUrl 2> /dev/null)

	if [[ -z $album_art ]]; then
		album_art=$(playerctl -p chromium metadata mpris:artUrl 2> /dev/null)

		if [[ -z $album_art ]]; then
			exit
		else
			set $(echo "$album_art" | sed "s/file...//")
			exit
		fi
	fi
fi

CAD=~/.cache/spotifyPictureCache

if [[ ! -d "$CAD" ]]; then
	mkdir $CAD
fi

cd $CAD || exit

file=$(echo "$album_art" | sed 's|.*/||')

if ! [ -f "$file" ]; then
	wget -c "${album_art}" -q
fi

set "$CAD/$file"
