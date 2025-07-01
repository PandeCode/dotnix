#!/usr/bin/env bash

vol=$(pamixer --get-volume)

if ((vol > 100)); then
	echo "#ff5555 $vol"
else
	echo "#8F93A2 $vol"
fi
