#!/usr/bin/env bash

if pgrep -x librewolf >/dev/null; then
	exec librewolf --new-window "$@"
elif pgrep -x chromium >/dev/null; then
	exec chromium --new-window "$@"
else
	exec librewolf "$@"
fi
