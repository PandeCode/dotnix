#/usr/bin/env bash

# https://unix.stackexchange.com/a/545840

WORKSPACE=$1
WKSP=$(xprop -root -notype _NET_CURRENT_DESKTOP | sed 's#.* =##')
CURRENT_WORKSPACE=$(expr 1 + $WKSP)
if [ $CURRENT_WORKSPACE -ne $WORKSPACE ]; then
	scrot -q 50 PRTSRC.jpeg
	feh PRTSRC.jpeg &
	FEH_WINDOW=$!
	#WAIT (give i3 time to switch workspace in the background)
	sleep .2
fi
slide_FEH_LEFT() {
	LONG_LINE="move left 1px"
	for i in {1..11}; do
		LONG_LINE=$LONG_LINE","$LONG_LINE
	done
	i3-msg "[class=feh] $LONG_LINE"
}
slide_FEH_RIGHT() {
	LONG_LINE="move right 1px"
	for i in {1..11}; do
		LONG_LINE=$LONG_LINE","$LONG_LINE
	done
	i3-msg "[class=feh] $LONG_LINE"
}

slide_FEH_DOWN_wmctrl() {
	FEH_ID=$(wmctrl -l | grep "PRTSRC.jpeg$" | awk '{print $1}')
	for ((c = 0; c != 1100; c = c + 10)); do
		wmctrl -i -r $FEH_ID -e 1,0,$c,1920,1080
	done
}

if [ $CURRENT_WORKSPACE -gt $WORKSPACE ]; then
	slide_FEH_RIGHT
else
	slide_FEH_LEFT
fi
#SIMPLE KILL AFTER 500ms
{ sleep .5 && kill $FEH_WINDOW; } &
rm PRTSRC.jpeg
