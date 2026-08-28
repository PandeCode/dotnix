#!/usr/bin/env bash

if pgrep -x "librewolf" &>/dev/null; then
	librewolf "$@"
elif pgrep -x "chromium" &>/dev/null; then
	chromium "$@"
else
	librewolf "$@"
fi
