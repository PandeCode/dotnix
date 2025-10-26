#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 <window-manager-command>"
  exit 1
fi

WM_CMD="$@"

Xephyr :1 -screen 1280x720 -br -reset -terminate &
XEPHYR_PID=$!

sleep 1

export DISPLAY=:1
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP="$WM_CMD"
export DESKTOP_SESSION="$WM_CMD"
export XDG_SEAT=seat0
export XDG_VTNR=1
export GDMSESSION="$WM_CMD"
export WINDOW_MANAGER="$WM_CMD"
export SESSION_MANAGER="local/localhost:$DISPLAY"
export XAUTHORITY="/tmp/xtest.$USER.auth"

touch "$XAUTHORITY"
xauth add :1 . "$(mcookie)"

$TERMINAL > /dev/null 2> /dev/null &
$WM_CMD

wait $XEPHYR_PID
