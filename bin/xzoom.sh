#!/usr/bin/env bash

# Name of your display (find with `xrandr | grep " connected"`)
DISPLAY_NAME=$(xrandr | grep " connected" | cut -d' ' -f1 | head -n1)

# Current scale factor, stored in a temp file
SCALE_FILE="/tmp/x11_zoom_scale"

# Default scale (no zoom)
DEFAULT_SCALE=1.0

# Zoom step (change how much zoom changes per step)
ZOOM_STEP=0.1

# Read current scale or set default
if [ -f "$SCALE_FILE" ]; then
    CURRENT_SCALE=$(cat "$SCALE_FILE")
else
    CURRENT_SCALE=$DEFAULT_SCALE
fi

# Function to apply the scale
apply_scale() {
    local scale=$1
    # Reset transform then apply scale
    xrandr --output "$DISPLAY_NAME" --scale "${scale}x${scale}"
    echo $scale > "$SCALE_FILE"
    echo "Zoom scale set to $scale"
}

case "$1" in
    in)
        # Zoom in = scale down (less than 1)
        NEW_SCALE=$(echo "$CURRENT_SCALE - $ZOOM_STEP" | bc)
        # Don't go below 0.1 scale
        if (( $(echo "$NEW_SCALE < 0.1" | bc -l) )); then
            NEW_SCALE=0.1
        fi
        apply_scale $NEW_SCALE
        ;;
    out)
        # Zoom out = scale up (greater than 1)
        NEW_SCALE=$(echo "$CURRENT_SCALE + $ZOOM_STEP" | bc)
        # Limit zoom out max 3x
        if (( $(echo "$NEW_SCALE > 3.0" | bc -l) )); then
            NEW_SCALE=3.0
        fi
        apply_scale $NEW_SCALE
        ;;
    reset)
        apply_scale $DEFAULT_SCALE
        ;;
    *)
        echo "Usage: $0 {in|out|reset}"
        echo "Zoom in/out/reset on X11 display $DISPLAY_NAME"
        ;;
esac
