#!/usr/bin/env bash

CACHE_FILE="$HOME/.cache/wpi-rdp.cache"

source "$HOME/wpi/rdp-auth.sh"

SERVERS=(
  # Makaroff
  "arc-research-01"

  "arc-research-09"
  "arc-research-10"
  "arc-research-11"

  # other
  "arc-teach-01" # solid works
  "elabs"        # solid works
  "windows"

  "matlab01"
  "matlab02"
)

if [[ -f "$CACHE_FILE" ]]; then
  LAST_SERVER="$(<"$CACHE_FILE")"
  SERVERS=("$LAST_SERVER" "${SERVERS[@]}")
fi

SERVER="$(printf '%s\n' "${SERVERS[@]}" | awk '!seen[$0]++' | rofi -dmenu -p "choose server")"
[[ -n "$SERVER" ]] || exit 0

printf '%s\n' "$SERVER" >"$CACHE_FILE"
notify-send "RDP" "Connecting $USER to $SERVER.wpi.edu"

yes | xfreerdp \
  "/v:$SERVER.wpi.edu" \
  "/u:$USER" \
  "/p:$PASS" \
  /dynamic-resolution \
  /clipboard \
  +auto-reconnect \
  "$@"
