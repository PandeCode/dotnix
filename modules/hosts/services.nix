{
  pkgs,
  lib,
  config,
  sharedConfig,
  ...
}: {
  imports = [
    # ./services/usbnotify.nix
    # ./services/sunshine.nix
    ./power.nix
  ];

  options = {
    services.isLaptop = lib.mkEnableOption "enables services";
  };

  config = {
    programs = {
      kdeconnect.enable = true;
      localsend.enable = false;
      weylus = {
        enable = true;
        openFirewall = true;
      };
    };

    services = {
      # rustdesk-server = {
      #   enable = true;
      #   openFirewall = true;
      # };

      syncthing = {
        enable = true;
        openDefaultPorts = true;

        settings = {
          devices = {
            # "smalldevice" = {id = "DEVICE-ID-GOES-HERE";};
            "rdevice" = {id = "5BOTQET-XOI5KOV-LOPRNME-LZ4CTNA-5FKYHKS-QHFBMNZ-B2D5MRY-4NBEUQA";};
            # "chaos" = {id = "DEVICE-ID-GOES-HERE";};
          };
          folders = {
            "main" = {
              path = "/home/${sharedConfig.user}/vaults/main";
              devices = ["rdevice"];
              ignorePerms = false;
            };
          };
        };
      };

      # printing.enable = true;

      gvfs.enable = true; # for charon-shell

      avahi = {
        enable = true;
        nssmdns4 = true; # printing
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
          userServices = true;
        };
      };

      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = lib.mkForce "no";
          X11Forwarding = true;
        };
      };
      printing.enable = false;

      qemuGuest.enable = false;
      # udev rules configuration for gaming controllers and power management
      udev = {
        packages = [
          # android-udev-rules
        ];
        extraRules = let
          TI = "";
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
            KERNEL=="uinput", MODE="0660", GROUP="${sharedConfig.user}", OPTIONS+="static_node=uinput"

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
  };
}
