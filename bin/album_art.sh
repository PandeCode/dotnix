#!/usr/bin/env bash

album_art=$(playerctl -p spotify metadata mpris:artUrl)

if [[ -z $album_art ]]; then
	# spotify is dead, we should die too.
	exit
fi

CAD=~/.cache/spotifyPictureCache
mkdir -p $CAD
cd $CAD || exit

file=$(echo "$album_art" | sed 's|.*/||')

if [ -f "$file" ]; then
	:
else
	wget -c "${album_art}" -q
fi

echo "$CAD/$file"
