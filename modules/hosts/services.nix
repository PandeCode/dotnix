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
            "small-device" = {id = "DEVICE-ID-GOES-HERE";};
            "device" = {id = "DEVICE-ID-GOES-HERE";};
            "chaos" = {id = "DEVICE-ID-GOES-HERE";};
          };
          folders = {
            "School" = {
              path = "/home/${sharedConfig.user}/Vaults/School";
              devices = ["device" "chaos"];
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
        settings.PermitRootLogin = lib.mkForce "yes";
      };
      printing.enable = false;

      qemuGuest.enable = false;
      # udev rules configuration for gaming controllers and power management
      udev = {
        packages = with pkgs; [
          android-udev-rules
        ];
        extraRules = ''
          # Steam Controller support
          # Basic functionality in Steam and keyboard/mouse emulation
          SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

          # Gamepad emulation support
          KERNEL=="uinput", MODE="0660", GROUP="shawn", OPTIONS+="static_node=uinput"

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
