#!/usr/bin/env bash
PING=$(ping -c4 1.1.1.1 | tail -n1 | cut -d'/' -f5)

# Fallback if ping fails
if [[ -z "$PING" ]]; then
  ICON="ban"         # No network
  STATE="Critical"
  TEXT="N/A"
else
  ICON="wifi"        # Default
  STATE="Idle"
  TEXT="${PING}"

  # Classify ping and update icon/state
  if [[ $(echo "$PING < 50" | bc) -eq 1 ]]; then
    ICON="signal"    # Excellent
    STATE="Good"
  elif [[ $(echo "$PING < 100" | bc) -eq 1 ]]; then
    ICON="exchange"  # Okay
    STATE="Info"
  else
    ICON="tachometer" # Bad
    STATE="Warning"
  fi
fi

echo "{\"icon\":\"$ICON\",\"text\":\"$TEXT\",\"state\":\"$STATE\"}"
