#!/usr/bin/env bash

# Virtual Display Manager
# Creates virtual monitors using various methods to work around hardware limitations

set -euo pipefail

# Configuration
RESOLUTION="1920x1080"
REFRESH_RATE="60"
DEFAULT_POSITION="left"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if required tools are available
check_dependencies() {
    local deps=("xrandr" "cvt")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing[*]}"
        log_info "Install with: sudo apt install x11-xserver-utils"
        exit 1
    fi
}

# Get primary display
get_primary_display() {
    local primary
    primary=$(xrandr --query | grep "connected primary" | cut -d' ' -f1)

    if [[ -z "$primary" ]]; then
        primary=$(xrandr --query | grep " connected" | head -1 | cut -d' ' -f1)
    fi

    echo "$primary"
}

# Find available virtual output
find_virtual_output() {
    local outputs
    outputs=$(xrandr --query | grep " disconnected" | cut -d' ' -f1)

    if [[ -n "$outputs" ]]; then
        echo "$outputs" | head -1
        return 0
    fi

    return 1
}

# Create xrandr virtual display
create_xrandr_display() {
    local primary="$1"
    local position="$2"
    local virtual_output

    if ! virtual_output=$(find_virtual_output); then
        log_error "No disconnected outputs available"
        return 1
    fi

    log_info "Using virtual output: $virtual_output"
    log_info "Position: $position of $primary"

    # Generate modeline
    local modeline
    modeline=$(cvt ${RESOLUTION/x/ } "$REFRESH_RATE" | tail -1)
    local mode_name
    mode_name=$(echo "$modeline" | awk '{print $2}' | sed 's/"//g')
    local mode_params
    mode_params=$(echo "$modeline" | cut -d' ' -f3-)

    log_info "Creating mode: $mode_name"

    # Create and add mode
    if xrandr --newmode "$mode_name" $mode_params 2>/dev/null; then
        log_success "Mode created successfully"
    else
        log_warning "Mode already exists or creation failed"
    fi

    if ! xrandr --addmode "$virtual_output" "$mode_name" 2>/dev/null; then
        log_error "Failed to add mode to output"
        return 1
    fi

    # Set position
    local position_flag
    case "$position" in
        left) position_flag="--left-of" ;;
        right) position_flag="--right-of" ;;
        above) position_flag="--above" ;;
        below) position_flag="--below" ;;
        *) position_flag="--left-of" ;;
    esac

    # Try to enable the display
    if xrandr --output "$virtual_output" --mode "$mode_name" "$position_flag" "$primary" 2>/dev/null; then
        log_success "Virtual display created: $virtual_output ($position of $primary)"
        return 0
    else
        log_error "Failed to enable virtual display (likely CRTC limitation)"
        xrandr --output "$virtual_output" --off 2>/dev/null || true
        return 1
    fi
}

# Create Xvfb virtual display
create_xvfb_display() {
    local display_num=99

    if ! command -v Xvfb &> /dev/null; then
        log_error "Xvfb not installed"
        log_info "Install with: sudo apt install xvfb"
        return 1
    fi

    # Kill existing Xvfb
    pkill -f "Xvfb :$display_num" 2>/dev/null || true
    sleep 1

    log_info "Starting Xvfb on display :$display_num"

    # Start Xvfb
    Xvfb ":$display_num" -screen 0 "${RESOLUTION}x24" -ac &
    local pid=$!

    sleep 2

    if kill -0 "$pid" 2>/dev/null; then
        echo "$pid" > /tmp/dummy_monitor_xvfb.pid
        log_success "Xvfb started (PID: $pid)"
        log_info "Use with: DISPLAY=:$display_num <application>"
        log_info "Example: DISPLAY=:$display_num firefox"
        return 0
    else
        log_error "Failed to start Xvfb"
        return 1
    fi
}

# Show system information
show_system_info() {
    log_info "Display Information"
    echo
    echo "Connected displays:"
    xrandr --query | grep " connected" | while read -r line; do
        echo "  $line"
    done

    echo
    echo "Disconnected outputs:"
    local disconnected
    disconnected=$(xrandr --query | grep " disconnected" | cut -d' ' -f1)
    if [[ -n "$disconnected" ]]; then
        echo "$disconnected" | sed 's/^/  /'
    else
        echo "  None"
    fi

    echo
    echo "Graphics hardware:"
    lspci | grep -i vga | sed 's/^/  /'

    echo
    local crtc_count
    crtc_count=$(xrandr --verbose | grep -c "CRTC:" || echo "0")
    local connected_count
    connected_count=$(xrandr --query | grep -c " connected" || echo "0")

    echo "CRTCs available: $crtc_count"
    echo "Displays connected: $connected_count"

    if [[ "$connected_count" -ge "$crtc_count" ]]; then
        log_warning "System may not support additional displays (CRTC limitation)"
    else
        log_success "System should support additional displays"
    fi
}

# Create virtual display (main function)
create_virtual_display() {
    local position="${1:-$DEFAULT_POSITION}"
    local primary

    primary=$(get_primary_display)
    if [[ -z "$primary" ]]; then
        log_error "Could not find primary display"
        return 1
    fi

    log_info "Primary display: $primary"
    log_info "Target resolution: $RESOLUTION @ ${REFRESH_RATE}Hz"

    # Try xrandr method first
    log_info "Attempting xrandr method..."
    if create_xrandr_display "$primary" "$position"; then
        return 0
    fi

    echo
    log_warning "Hardware method failed, trying software alternatives..."
    echo

    # Try Xvfb method
    log_info "Attempting Xvfb method..."
    if create_xvfb_display; then
        return 0
    fi

    echo
    log_error "All methods failed"
    echo
    log_info "Alternative solutions:"
    echo "  1. Install dummy video driver: sudo apt install xserver-xorg-video-dummy"
    echo "  2. Use window manager workspaces as virtual screens"
    echo "  3. Use VNC for virtual display: sudo apt install x11vnc"
    echo "  4. Consider hardware solutions (USB display adapters)"

    return 1
}

# Remove virtual displays
remove_virtual_displays() {
    log_info "Cleaning up virtual displays..."

    # Remove xrandr virtual outputs
    local removed=0
    while read -r output; do
        if [[ -n "$output" ]]; then
            log_info "Disabling $output"
            xrandr --output "$output" --off 2>/dev/null || true
            ((removed++))
        fi
    done < <(xrandr --query | grep -E "(VIRTUAL|VGA-|HDMI-|DP-).*connected [0-9]" | cut -d' ' -f1)

    # Clean up modes
    while read -r mode; do
        if [[ "$mode" =~ ^[0-9]+x[0-9]+_[0-9.]+$ ]]; then
            log_info "Removing mode: $mode"
            xrandr --rmmode "$mode" 2>/dev/null || true
        fi
    done < <(xrandr --query | grep -E "^\s+[0-9]+x[0-9]+_[0-9.]+" | awk '{print $1}')

    # Kill Xvfb
    if [[ -f /tmp/dummy_monitor_xvfb.pid ]]; then
        local pid
        pid=$(cat /tmp/dummy_monitor_xvfb.pid)
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            log_success "Stopped Xvfb (PID: $pid)"
            ((removed++))
        fi
        rm -f /tmp/dummy_monitor_xvfb.pid
    fi

    # Kill any remaining Xvfb processes
    if pkill -f "Xvfb :" 2>/dev/null; then
        log_success "Cleaned up remaining Xvfb processes"
        ((removed++))
    fi

    if [[ $removed -eq 0 ]]; then
        log_info "No virtual displays found to remove"
    else
        log_success "Removed $removed virtual display(s)"
    fi
}

# Validate position argument
validate_position() {
    local position="$1"
    case "$position" in
        left|right|above|below) return 0 ;;
        *) return 1 ;;
    esac
}

# Show usage information
show_usage() {
    echo "Virtual Display Manager"
    echo
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  create [POSITION] - Create virtual display (default: $DEFAULT_POSITION)"
    echo "  remove           - Remove all virtual displays"
    echo "  show             - Show system display information"
    echo "  xvfb             - Create Xvfb virtual display only"
    echo "  help             - Show this help message"
    echo
    echo "Positions:"
    echo "  left    - Place virtual display to the left of primary"
    echo "  right   - Place virtual display to the right of primary"
    echo "  above   - Place virtual display above primary"
    echo "  below   - Place virtual display below primary"
    echo
    echo "Examples:"
    echo "  $0 create right     # Create virtual display on the right"
    echo "  $0 create           # Create virtual display on the left (default)"
    echo "  $0 xvfb             # Create Xvfb display only"
    echo "  $0 remove           # Remove all virtual displays"
    echo
    echo "Configuration:"
    echo "  Resolution: $RESOLUTION"
    echo "  Refresh rate: ${REFRESH_RATE}Hz"
    echo "  Default position: $DEFAULT_POSITION"
}

# Main function
main() {
    local command="${1:-create}"
    local position="${2:-$DEFAULT_POSITION}"

    check_dependencies

    case "$command" in
        create|add)
            if [[ -n "$position" ]] && ! validate_position "$position"; then
                log_error "Invalid position: $position"
                log_info "Valid positions: left, right, above, below"
                exit 1
            fi
            create_virtual_display "$position"
            ;;
        remove|delete|cleanup)
            remove_virtual_displays
            ;;
        show|info|status)
            show_system_info
            ;;
        xvfb)
            create_xvfb_display
            ;;
        help|-h|--help)
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            echo
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
