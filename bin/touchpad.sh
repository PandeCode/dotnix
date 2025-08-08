#!/usr/bin/env bash
# Universal Touchpad Control Script
# Supports both Sway (Wayland) and X11 environments
# Auto-detects the environment and uses appropriate commands

# Function to detect display server
detect_environment() {
    if [ -n "$WAYLAND_DISPLAY" ] && command -v swaymsg &> /dev/null; then
        echo "sway"
    elif [ -n "$DISPLAY" ] && command -v xinput &> /dev/null; then
        echo "x11"
    else
        echo "unknown"
    fi
}

# Sway/Wayland functions
sway_get_touchpad_state() {
    swaymsg -t get_inputs | jq -r '.[] | select(.type=="touchpad") | .libinput.send_events' | head -n 1
}

sway_enable_touchpad() {
    swaymsg input type:touchpad events enabled
    notify_user "Touchpad Enabled"
}

sway_disable_touchpad() {
    swaymsg input type:touchpad events disabled
    notify_user "Touchpad Disabled"
}

sway_toggle_touchpad() {
    local state=$(sway_get_touchpad_state)
    if [[ "$state" == "disabled" ]]; then
        sway_enable_touchpad
    else
        sway_disable_touchpad
    fi
}

sway_get_status() {
    local state=$(sway_get_touchpad_state)
    if [[ "$state" == "disabled" ]]; then
        echo "Touchpad is disabled"
        return 1
    else
        echo "Touchpad is enabled"
        return 0
    fi
}

# X11 functions
x11_find_touchpad() {
    # Common touchpad names/patterns
    local patterns=("TouchPad" "Touchpad" "touchpad" "Synaptics" "ELAN" "bcm5974")
    for pattern in "${patterns[@]}"; do
        local device=$(xinput list | grep -i "$pattern" | head -n1 | sed 's/.*id=\([0-9]*\).*/\1/')
        if [ -n "$device" ]; then
            echo "$device"
            return 0
        fi
    done
    # If no common patterns found, try to find pointer devices and exclude mouse
    local touchpad=$(xinput list | grep -E "↳.*slave.*pointer" | grep -v -i "mouse\|optical\|wireless" | head -n1 | sed 's/.*id=\([0-9]*\).*/\1/')
    if [ -n "$touchpad" ]; then
        echo "$touchpad"
        return 0
    fi
    return 1
}

x11_is_touchpad_enabled() {
    local device_id=$1
    local enabled=$(xinput list-props "$device_id" | grep "Device Enabled" | grep -o "[01]$")
    [ "$enabled" = "1" ]
}

x11_enable_touchpad() {
    local device_id=$1
    xinput enable "$device_id"
    echo "Touchpad enabled"
    notify_user "Touchpad enabled"
}

x11_disable_touchpad() {
    local device_id=$1
    xinput disable "$device_id"
    echo "Touchpad disabled"
    notify_user "Touchpad disabled"
}

x11_toggle_touchpad() {
    local device_id=$1
    if x11_is_touchpad_enabled "$device_id"; then
        x11_disable_touchpad "$device_id"
    else
        x11_enable_touchpad "$device_id"
    fi
}

x11_get_status() {
    local device_id=$1
    if x11_is_touchpad_enabled "$device_id"; then
        echo "Touchpad is enabled"
        return 0
    else
        echo "Touchpad is disabled"
        return 1
    fi
}

# Notification function
notify_user() {
    local message="$1"
    if command -v notify-send &> /dev/null; then
        notify-send "Touchpad" "$message" -i input-touchpad
    fi
}

# Main script logic
main() {
    local env=$(detect_environment)
    local action="${1:-toggle}"

    case "$env" in
        "sway")
            # Check if jq is available for Sway
            if ! command -v jq &> /dev/null; then
                echo "Error: jq is required for Sway support. Please install jq."
                exit 1
            fi

            case "$action" in
                "disable"|"off"|"0")
                    sway_disable_touchpad
                    ;;
                "enable"|"on"|"1")
                    sway_enable_touchpad
                    ;;
                "toggle"|"")
                    sway_toggle_touchpad
                    ;;
                "status")
                    sway_get_status
                    ;;
                *)
                    show_usage
                    exit 1
                    ;;
            esac
            ;;

        "x11")
            # Find touchpad device
            local touchpad_id=$(x11_find_touchpad)
            if [ -z "$touchpad_id" ]; then
                echo "Error: Could not find touchpad device."
                echo "Available input devices:"
                xinput list
                exit 1
            fi

            # Get touchpad name for display
            local touchpad_name=$(xinput list | grep "id=$touchpad_id" | sed 's/.*↳\s*\([^	]*\).*/\1/')
            echo "Found touchpad: $touchpad_name (ID: $touchpad_id)"

            case "$action" in
                "disable"|"off"|"0")
                    x11_disable_touchpad "$touchpad_id"
                    ;;
                "enable"|"on"|"1")
                    x11_enable_touchpad "$touchpad_id"
                    ;;
                "toggle"|"")
                    x11_toggle_touchpad "$touchpad_id"
                    ;;
                "status")
                    x11_get_status "$touchpad_id"
                    ;;
                *)
                    show_usage
                    exit 1
                    ;;
            esac
            ;;

        "unknown")
            echo "Error: Unable to detect display server environment."
            echo "This script requires either:"
            echo "  - Sway (Wayland) with swaymsg and jq"
            echo "  - X11 with xinput"
            echo ""
            echo "Current environment:"
            echo "  WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-not set}"
            echo "  DISPLAY: ${DISPLAY:-not set}"
            echo "  swaymsg available: $(command -v swaymsg &> /dev/null && echo "yes" || echo "no")"
            echo "  xinput available: $(command -v xinput &> /dev/null && echo "yes" || echo "no")"
            exit 1
            ;;
    esac
}

# Usage information
show_usage() {
    echo "Usage: $0 [disable|enable|toggle|status]"
    echo "  disable/off/0  - Disable touchpad"
    echo "  enable/on/1    - Enable touchpad"
    echo "  toggle         - Toggle touchpad state (default)"
    echo "  status         - Show current touchpad state"
    echo ""
    echo "Supports both Sway (Wayland) and X11 environments."
}

# Handle help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Run main function
main "$@"
