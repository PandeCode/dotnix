{
  config,
  lib,
  sharedConfig,
  pkgs,
  ...
}: {
  # Add required packages to system environment
  environment.systemPackages = with pkgs; [
    libnotify
    usbutils
    coreutils
    util-linux
  ];

  # Create the USB monitor script
  environment.etc."usb-monitor/usb-monitor.sh" = {
    mode = "0755";
    text =
      /*
      bash
      */
      ''
        #!/bin/sh

        # Log file location
        LOG_FILE="/var/log/usb-monitor.log"

        # Function to send notifications
        send_notification() {
            local event="$1"
            local device_info="$2"

            # Log to file
            echo "$(date): $event - $device_info" >> "$LOG_FILE"

            # Send desktop notification if DISPLAY is set
            if [ -n "$DISPLAY" ] && [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
                 su ${sharedConfig.user} -c "notify-send \"USB Device $event\" \"$device_info\" --icon=device-notifier"
            fi

        }

        touch "$LOG_FILE"
        echo "$(date): USB monitoring service started" >> "$LOG_FILE"

        # Use udevadm to monitor events
        monitor_usb() {
            while true; do
                # Use udevadm to monitor events
                ${pkgs.systemd}/bin/udevadm monitor --property --subsystem-match=usb --subsystem-match=input | while read line; do
                    # Check for added or removed devices
                    if echo "$line" | grep -q "DEVPATH"; then
                        devpath=$(echo "$line" | grep -o 'DEVPATH=.*' | cut -d= -f2)
                    elif echo "$line" | grep -q "ACTION=add"; then
                        action="connected"

                        # Get detailed device information
                        device_info=$(${pkgs.systemd}/bin/udevadm info --path="/sys$devpath" --query=all 2>/dev/null)

                        # Extract useful information
                        vendor=$(echo "$device_info" | grep -i "ID_VENDOR=" | cut -d= -f2)
                        product=$(echo "$device_info" | grep -i "ID_MODEL=" | cut -d= -f2)
                        serial=$(echo "$device_info" | grep -i "ID_SERIAL=" | cut -d= -f2)

                        # Format the notification message
                        if [ -n "$vendor" ] && [ -n "$product" ]; then
                            message="Device: $vendor $product"
                            [ -n "$serial" ] && message="$message\nSerial: $serial"
                            message="$message\nPath: $devpath"
                        else
                            message="Device at path: $devpath"
                        fi

                        send_notification "$action" "$message"

                    elif echo "$line" | grep -q "ACTION=remove"; then
                        action="disconnected"
                        send_notification "$action" "Device at path: $devpath"
                    fi
                done
            done
        }

        # Start monitoring
        monitor_usb
      '';
  };

  # Define the systemd service
  systemd.services.usb-monitor = {
    description = "USB Device Monitor Service";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash /etc/usb-monitor/usb-monitor.sh";
      Restart = "always";
      # Run as root since we need access to system devices
      User = "root";

      # Allow access to important directories
      ReadWritePaths = [
        "/var/log"
        "/sys"
      ];

      # For desktop notifications - adjust the user ID if needed
      Environment = [
        "DISPLAY=:0"
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
      ];
    };
  };

  # Create log directory with appropriate permissions
  systemd.tmpfiles.rules = [
    "d /var/log/usb-monitor 0755 root root -"
    "f /var/log/usb-monitor.log 0644 root root -"
  ];
}
