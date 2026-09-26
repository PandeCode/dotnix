{
  pkgs,
  lib,
  sharedConfig,
  ...
}: {
  imports = [
    # ./services/sunshine.nix
    ./power.nix
  ];

  services = {
    qemuGuest.enable = true;
    # udev rules configuration for gaming controllers and power management
    udev = {
      packages = [
        # android-udev-rules
      ];
      extraRules = let
        # notify =
        #   pkgs.writeShellScriptBin "notify-device.sh"
        #   ''
        #     #!/usr/bin/env bash
        #     set -euo pipefail
        #
        #     event="$1"   # "add" or "remove"
        #     devnode="\''${2:-}"
        #     id="\''${3:-}"
        #
        #     # logger -t nixos-device-event "event=$event devnode=$devnode id=${id}"
        #   '';
        #
        # ACTION=="add", SUBSYSTEM=="usb", RUN+="${/etc/nixos/device-event.sh} add %E{DEVNAME} %E{ID_SERIAL}"
        # ACTION=="remove", SUBSYSTEM=="usb", RUN+="${/etc/nixos/device-event.sh} remove %E{DEVNAME} %E{ID_SERIAL}"
        TI = "";

        AMD = ''
          ###########################################################################
          #                                                                         #
          #  52-digilent-usb.rules -- UDEV rules for Digilent USB Devices           #
          #                                                                         #
          ###########################################################################
          #  Author: MTA                                                            #
          #  Copyright 2010 Digilent Inc.                                           #
          ###########################################################################
          #  File Description:                                                      #
          #                                                                         #
          #  This file contains the rules used by UDEV when creating entries for    #
          #  Digilent USB devices. In order for Digilent's shared libraries and     #
          #  applications to access these devices without root privalages it is     #
          #  necessary for UDEV to create entries for which all users have read     #
          #  and write permission.                                                  #
          #                                                                         #
          #  Usage:                                                                 #
          #                                                                         #
          #  Copy this file to "/etc/udev/rules.d/" and execute                     #
          #  "/sbin/udevcontrol reload_rules" as root. This only needs to be done   #
          #  immediately after installation. Each time you reboot your system the   #
          #  rules are automatically loaded by UDEV.                                #
          #                                                                         #
          ###########################################################################
          #  Revision History:                                                      #
          #                                                                         #
          #  04/15/2010(MTA): created                                               #
          #  02/28/2011(MTA): modified to support FTDI based devices                #
          #  07/10/2012(MTA): modified to work with UDEV versions 098 or newer      #
          #  04/19/2013(MTA): modified mode assignment to use ":=" insetead of "="  #
          #       so that our permission settings can't be overwritten by other     #
          #       rules files                                                       #
          #  07/28/2014(MTA): changed default application path                      #
          #                                                                         #
          ###########################################################################

          # Create "/dev" entries for Digilent device's with read and write
          # permission granted to all users.
          ATTRS{idVendor}=="1443", MODE:="666"
          ACTION=="add", ATTRS{idVendor}=="0403", ATTRS{manufacturer}=="Digilent", MODE:="666"

          # The following rules (if present) cause UDEV to ignore all UEVENTS for
          # which the subsystem is "usb_endpoint" and the action is "add" or
          # "remove". These rules are necessary to work around what appears to be a
          # bug in the Kernel used by Red Hat Enterprise Linux 5/CentOS 5. The Kernel
          # sends UEVENTS to remove and then add entries for the endpoints of a USB
          # device in "/dev" each time a process releases an interface. This occurs
          # each time a data transaction occurs. When an FPGA is configured or flash
          # device is written a large number of transactions take place. If the
          # following lines are commented out then UDEV will be overloaded for a long
          # period of time while it tries to process the massive number of UEVENTS it
          # receives from the kernel. Please note that this work around only applies
          # to systems running RHEL5 or CentOS 5 and as a result the rules will only
          # be present on those systems.
          ###########################################################################
          #                                                                         #
          #  52-xilinx-ftdi-usb.rules -- UDEV rules for Xilinx USB Devices          #
          #                                                                         #
          ###########################################################################
          #  Author: EST                                                            #
          #  Copyright 2016 Xilinx Inc.                                             #
          ###########################################################################
          #  File Description:                                                      #
          #                                                                         #
          #  This file contains the rules used by UDEV when creating entries for    #
          #  Xilinx USB devices. In order for Xilinx's shared libraries and         #
          #  applications to access these devices without root privalages it is     #
          #  necessary for UDEV to create entries for which all users have read     #
          #  and write permission.                                                  #
          #                                                                         #
          #  Usage:                                                                 #
          #                                                                         #
          #  Copy this file to "/etc/udev/rules.d/" and execute                     #
          #  "/sbin/udevcontrol reload_rules" as root. This only needs to be done   #
          #  immediately after installation. Each time you reboot your system the   #
          #  rules are automatically loaded by UDEV.                                #
          #                                                                         #
          ###########################################################################
          #  Revision History:                                                      #
          #                                                                         #
          # 06/13/2025(EST): Add support for newer linux kernel                     #
          # 10/18/2016(EST): created                                                #
          #                                                                         #
          ###########################################################################
          # version 0002

          # Unbind default ftdi_sio kernel driver
          ATTRS{idVendor}=="0403", ATTRS{bInterfaceNumber}=="00",\
          PROGRAM="/bin/sh -c '\
              echo -n $id:1.0 > /sys/bus/usb/drivers/ftdi_sio/unbind;\
              echo -n $id:1.1 > /sys/bus/usb/drivers/ftdi_sio/unbind\
          '"
          # Create "/dev" entries for Xilinx device's with read and write
          # permission granted to all users.
          ACTION=="add", ATTRS{idVendor}=="0403", MODE:="666"

          # The following rules (if present) cause UDEV to ignore all UEVENTS for
          # which the subsystem is "usb_endpoint" and the action is "add" or
          # "remove". These rules are necessary to work around what appears to be a
          # bug in the Kernel used by Red Hat Enterprise Linux 6/CentOS 5. The Kernel
          # sends UEVENTS to remove and then add entries for the endpoints of a USB
          # device in "/dev" each time a process releases an interface. This occurs
          # each time a data transaction occurs. When an FPGA is configured or flash
          # device is written a large number of transactions take place. If the
          # following lines are commented out then UDEV will be overloaded for a long
          # period of time while it tries to process the massive number of UEVENTS it
          # receives from the kernel. Please note that this work around only applies
          # to systems running RHEL6 or CentOS 5 and as a result the rules will only
          # be present on those systems.
          # version 0002
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="0008", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="0007", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="0009", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="000d", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="000f", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="0013", MODE="666"
          ATTR{idVendor}=="03fd", ATTR{idProduct}=="0015", MODE="666"
        '';

        TI_ = ''
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d0",MODE:="0666"
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d1",MODE:="0666"
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6010",MODE:="0666"
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1cbe",ATTRS{idProduct}=="00fd",MODE:="0666"
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1cbe",ATTRS{idProduct}=="00ff",MODE:="0666"
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef1",MODE:="0666"
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef2",MODE:="0666"
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef3",MODE:="0666"
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef4",MODE:="0666"
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="f432",MODE:="0666"
          SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0d28",ATTRS{idProduct}=="0204",MODE:="0666"
          KERNEL=="hidraw*",ATTRS{busnum}=="*",ATTRS{idVendor}=="0d28",ATTRS{idProduct}=="0204",MODE:="0666"
          ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef0",ENV{ID_MM_DEVICE_IGNORE}="1"
          ATTRS{idVendor}=="0c55",ATTRS{idProduct}=="0220",ENV{ID_MM_DEVICE_IGNORE}="1"
          KERNEL=="ttyACM[0-9]*",MODE:="0666"

          SUBSYSTEM=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="c32a", MODE="0660", GROUP="dialout", RUN+="/sbin/modprobe ftdi-sio" RUN+="/bin/sh -c '/bin/echo 0451 c32a > /sys/bus/usb-serial/drivers/ftdi_sio/new_id'"

        '';
      in
        TI
        + AMD
        + ''
          # Arduino
          KERNEL=="ttyACM[0-9]*", MODE="0666"

          # TI MSP430 (TI vendor ID)
          SUBSYSTEM=="usb", ATTR{idVendor}=="0451", MODE="0666"
          # KERNEL=="hidraw*", ATTRS{idVendor}=="0451", MODE="0666"

          # Steam Controller support
          # Basic functionality in Steam and keyboard/mouse emulation
          SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

          # Gamepad emulation support
          KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"

          # Weylus tablet input support
          KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"

          # Valve HID devices
          KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"
          KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"

          # DualShock 4 Controller support
          # DualShock 4 over USB
          KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666"
          # DualShock 4 wireless adapter over USB
          KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0666"
          # DualShock 4 Slim over USB
          KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666"
          # DualShock 4 over Bluetooth
          KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0666"
          # DualShock 4 Slim over Bluetooth
          KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0666"

          # Hard drive power management
          # Set aggressive power saving for rotational drives
          ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 41 /dev/%k"

        '';
    };
  };
}
