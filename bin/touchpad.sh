#!/usr/bin/env bash

# Touchpad disable/enable script for Linux (Desktop Environment Agnostic)
# Uses xinput to control touchpad state

# Function to find touchpad device
find_touchpad() {
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

# Function to check if touchpad is enabled
is_touchpad_enabled() {
    local device_id=$1
    local enabled=$(xinput list-props "$device_id" | grep "Device Enabled" | grep -o "[01]$")
    [ "$enabled" = "1" ]
}

# Function to toggle touchpad
toggle_touchpad() {
    local device_id=$1

    if is_touchpad_enabled "$device_id"; then
        xinput disable "$device_id"
        echo "Touchpad disabled"

        # Optional: Show notification if notify-send is available
        if command -v notify-send &> /dev/null; then
            notify-send "Touchpad" "Touchpad disabled" -i input-touchpad
        fi
    else
        xinput enable "$device_id"
        echo "Touchpad enabled"

        # Optional: Show notification if notify-send is available
        if command -v notify-send &> /dev/null; then
            notify-send "Touchpad" "Touchpad enabled" -i input-touchpad
        fi
    fi
}

# Function to disable touchpad
disable_touchpad() {
    local device_id=$1
    xinput disable "$device_id"
    echo "Touchpad disabled"

    if command -v notify-send &> /dev/null; then
        notify-send "Touchpad" "Touchpad disabled" -i input-touchpad
    fi
}

# Function to enable touchpad
enable_touchpad() {
    local device_id=$1
    xinput enable "$device_id"
    echo "Touchpad enabled"

    if command -v notify-send &> /dev/null; then
        notify-send "Touchpad" "Touchpad enabled" -i input-touchpad
    fi
}

# Main script logic
main() {
    # Check if xinput is available
    if ! command -v xinput &> /dev/null; then
        echo "Error: xinput not found. Please install xorg-xinput package."
        exit 1
    fi

    # Find touchpad device
    touchpad_id=$(find_touchpad)

    if [ -z "$touchpad_id" ]; then
        echo "Error: Could not find touchpad device."
        echo "Available input devices:"
        xinput list
        exit 1
    fi

    # Get touchpad name for display
    touchpad_name=$(xinput list | grep "id=$touchpad_id" | sed 's/.*↳\s*\([^	]*\).*/\1/')
    echo "Found touchpad: $touchpad_name (ID: $touchpad_id)"

    # Process command line arguments
    case "${1:-toggle}" in
        "disable"|"off"|"0")
            disable_touchpad "$touchpad_id"
            ;;
        "enable"|"on"|"1")
            enable_touchpad "$touchpad_id"
            ;;
        "toggle"|"")
            toggle_touchpad "$touchpad_id"
            ;;
        "status")
            if is_touchpad_enabled "$touchpad_id"; then
                echo "Touchpad is enabled"
            else
                echo "Touchpad is disabled"
            fi
            ;;
        *)
            echo "Usage: $0 [disable|enable|toggle|status]"
            echo "  disable/off/0  - Disable touchpad"
            echo "  enable/on/1    - Enable touchpad"
            echo "  toggle         - Toggle touchpad state (default)"
            echo "  status         - Show current touchpad state"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
