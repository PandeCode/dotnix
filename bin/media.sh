#!/usr/bin/env bash

DEFAULT_PLAYER=spotify
DEFAULT_SINK=spotify
CURRENT_SINK_FILE=/tmp/currentSinkFile
CURRENT_PLAYER_FILE=/tmp/currentPlayerFile
PICTURE_CACHE_DIR=$HOME/.cache/spotifyPictureCache
IMAGE_SIZE=16x16
DISPLAY_ICON=true
PROGRESS_WIDTH=2
PROGRESS_POSITION=bottom # Top | Bottom
PROGRESS_COLOR="#84ffff"

DELIMITER_1="🗘" # It is there just not rendered easily
DELIMITER_1="🗘" # It is there just not rendered easily

function makeSafeForSed() {
	str="$1"
	strlen=${#str}
	for ((i = 0; i < ${strlen}; i++)); do
		char=${str:$i:1}
		if [ "$char" == "/" ]; then
			echo -n "\\/"
		else
			echo -n "$char"
		fi
	done
}

function isProcessRunning() {
	pid=$1
	kill -0 "$pid" 2>/dev/null
	return $?
}

function getCurrentPlayer() {

	if [ -f "$CURRENT_PLAYER_FILE" ]; then
		c=$(cat $CURRENT_PLAYER_FILE)
		players=($(playerctl -l))
		if [[ " ${players[*]} " =~ " ${c} " ]]; then
			echo -n $c
			return
		fi
	fi

	echo -n "$(getNewCurrentPlayer)"
}

currentPlayer=$(getCurrentPlayer)

function getNewCurrentPlayer() {
	players=$(playerctl -l)

	for p in $players; do
		if [ "$DEFAULT_PLAYER" = "$p" ]; then
			echo -n $p >$CURRENT_PLAYER_FILE
			echo -n $p
			return
		fi
	done

	for p in $players; do
		echo -n $p >$CURRENT_PLAYER_FILE
		echo -n $p
		return
	done
}

function setCurrentPlayer() {
	echo -n $1 >$CURRENT_PLAYER_FILE
}

function playerNotFound() {
	notify-send "Player Not Found" "Start a player like spotify or a youtube video." -u critical -t 3000
}

function applyProgress() {
	info=$1
	infoLen=${#info}
	data=$(playerctl metadata -p $currentPlayer -f '{{ position }} {{ mpris:length }}')
	length=$(echo -n "$data" | awk '{print $2}')
	numChars=$(echo -n "$data" | awk "{ printf(\"%.f\", $infoLen * (\$1/\$2))}")

	first=""
	second=""
	for ((i = 0; i < infoLen; i++)); do
		char=${info:$i:1}
		seek=$(echo -n "$i $infoLen" | awk "{ printf(\"%.f\", 0.000001*($length*($i/$infoLen)))}")

		if (($i > $numChars)); then
			# second+="<action=\`playerctl -p $currentPlayer position $seek\`>$char</action>"
			second+="$char"
		else
			# first+="<action=\`playerctl -p $currentPlayer position $seek\`>$char</action>"
			first+="$char"
		fi
	done

	echo -n "<span style=\"border-bottom:${PROGRESS_WIDTH}px solid $PROGRESS_COLOR\">$first</span>$second"
}

function sinkNotFound() {
	notify-send "Sink Not Found" "Start a player like spotify or a youtube video." -u critical -t 3000
}

function setCurrentSink() {
	echo -n $1 >$CURRENT_SINK_FILE
}

function getSink() {
	pactl list sink-inputs |
		grep "\(Sink Input\|media.name\)" |
		perl -pe 's/(\t)//; s/\s*//; s/\n//; s/Sink Input #/\n/; s/^(\s|\t|\")*$//;s/"//; s/"// ;s/media.name = / /' |
		grep $1 |
		cut -d ' ' -f 1 | tr '
' ' ' | sed 's/ //'

	if [ $? -ne 0 ]; then
		sinkNotFound
		setCurrentSink $DEFAULT_SINK
	fi
}

function getSinks() {
	pactl list sink-inputs |
		grep "\(Sink Input\|media.name\)" |
		perl -pe 's/(\t)//; s/\s*//; s/\n//; s/Sink Input #/\n/; s/^(\s|\t|\")*$//;s/"//; s/"// ;s/media.name = / /' | sed -r '/^\s*$/d'
}

function getCurrentSink() {
	if [ -f "$CURRENT_SINK_FILE" ]; then
		cat $CURRENT_SINK_FILE
	else
		setCurrentSink $(getSink Spotify)
		echo -n Spotify | tee $CURRENT_SINK_FILE
	fi
}

case $1 in
1)
	playerctl -p $currentPlayer play-pause
	exit 0
	;;

2)
	$DOTFILES/scripts/dwm/media.sh
	#spotymenu
	exit 0
	;;

3)
	players=""
	for p in $(playerctl -l); do
		players+="	$p	setCurrentPlayer $p > $CURRENT_PLAYER_FILE
"
	done
	if [ -z "$players" ]; then
		players='	None	playerNotFound'
	else
		players+="	"
	fi

	sinks=""
	while IFS= read -r line; do
		sinkNumber=$(echo $line | awk '{print($1)}')
		sinkName=$(echo $line | awk '{print($2)}')
		sinks+="	$sinkName	setCurrentSink $sinkNumber > $CURRENT_SINK_FILE"
	done <<<"$(getSinks)"

	if [ -z "$sinks" ]; then
		sinks='	None	sinkNotFound'
	else
		sinks+="	"
	fi

	cmd="$(
		cat <<EOF | xmenu
Player
$players

Sinks
$sinks

Control
	Play-Pause	playerctl --player=$currentPlayer  play-pause
	Next    	playerctl --player=$currentPlayer  next
	Previous	playerctl --player=$currentPlayer  previous
	Play    	playerctl --player=$currentPlayer  play
	Pause   	playerctl --player=$currentPlayer  pause
	Stop    	playerctl --player=$currentPlayer  stop
EOF
	)"

	$cmd
	exit 0
	;;

4)
	pactl set-sink-input-volume "$(getCurrentSink)" +10%
	exit 0
	;;

5)
	pactl set-sink-input-volume "$(getCurrentSink)" -10%
	exit 0
	;;

source)
	exit 0
	;;

esac

function getAlbmuArt() {
	artUrl=$(playerctl metadata -p spotify --format "{{ mpris:artUrl }}")
	fileName=$(echo $artUrl | grep -Po '.*/\K.*')
	fileNameXpm="$(echo $fileName).xpm"

	if ! [ -f $PICTURE_CACHE_DIR/$fileName ]; then
		wget -O $PICTURE_CACHE_DIR/$fileName $artUrl

		cd $PICTURE_CACHE_DIR
		magick $fileName -resize $IMAGE_SIZE $fileNameXpm
	fi

	if ! [ -f $fileNameXpm ]; then
		cd $PICTURE_CACHE_DIR
		magick $fileName -resize $IMAGE_SIZE $fileNameXpm
	fi

	echo $PICTURE_CACHE_DIR/$fileNameXpm
}

iconText=''
if [ "$DISPLAY_ICON" = true ] && [ "$currentPlayer" = "spotify" ]; then
	album_art="$(getAlbmuArt)"
	# iconText="<span style='background-image: url(\"${album_art}\");'></span>"
	iconText="hello"
fi

info=$(playerctl metadata -p $currentPlayer --format '{{ artist }} ----- {{ title }}')
title="$(grep -Po '(?<=----- ).*' <<<$info)"
artist="$(grep -Po '.*(?= -----)' <<<$info)"
finalInfo=''
if ! [ -z "$artist" ]; then
	finalInfo+="$artist - "
fi
if ! [ -z "$title" ]; then
	finalInfo+="$(perl -pe 's/^Watch //; s/ English Subbed Online Free//' <<<$title)"
fi

progressedInfo=$(applyProgress "$DELIMITER_1$finalInfo")
echo -n "$iconText"
echo -n "$progressedInfo" | sed "s/&/&amp;/"
