#!/usr/bin/env bash

battery=$(</sys/class/power_supply/BAT1/capacity)

if ((battery >= 100)); then
	color="#50fa7b" # green
elif ((battery >= 40)); then
	color="#8F93A2" # normal gray
elif ((battery >= 20)); then
	color="#f1fa8c" # warning yellow
else
	color="#ff5555" # critical red
fi

echo "$color ${battery}"
