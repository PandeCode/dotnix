{
  pkgs,
  lib,
  config,
  sharedConfig,
  ...
}: let
  cfg = config.services;
in {
  imports = [
    # ./services/usbnotify.nix
    # ./services/sunshine.nix
  ];

  options = {
    services.isLaptop = lib.mkEnableOption "enables services";
  };

  config = {
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
    programs = {
      kdeconnect.enable = true;
      localsend.enable = true;
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
            "device" = {id = "DEVICE-ID-GOES-HERE";};
            "chaos" = {id = "DEVICE-ID-GOES-HERE";};
          };
          folders = {
            "School" = {
              path = "/home/${sharedConfig.username}/Vaults/School";
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
          addresses = true;
          workstation = true;
          userServices = true;
        };
      };

      openssh = {
        enable = true;
        settings.PermitRootLogin = lib.mkForce "yes";
      };
      printing.enable = true;
      qemuGuest.enable = true;
      # tlp = lib.mkIf cfg.isLaptop {
      #   enable = true;
      #   settings = {
      #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
      #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      #
      #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      #
      #     CPU_MIN_PERF_ON_AC = 0;
      #     CPU_MAX_PERF_ON_AC = 100;
      #     CPU_MIN_PERF_ON_BAT = 0;
      #     CPU_MAX_PERF_ON_BAT = 20;
      #
      #     # Optional helps save long term battery health
      #     START_CHARGE_THRESH_BAT0 = 20; # 40 and bellow it starts to charge
      #     STOP_CHARGE_THRESH_BAT0 = 90; # 80 and above it stops charging
      #   };
      # };
      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
      udev.extraRules =
        ''
          # This rule is needed for basic functionality of the controller in
          # Steam and keyboard/mouse emulation
          SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

          # This rule is necessary for gamepad emulation; make sure you
          # replace 'pgriffais' with a group that the user that runs Steam
          # belongs to
          KERNEL=="uinput", MODE="0660", GROUP="pgriffais", OPTIONS+="static_node=uinput"

          # Valve HID devices over USB hidraw
          KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"

          # Valve HID devices over bluetooth hidraw
          KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"

          # DualShock 4 over USB hidraw
          KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666"

          # DualShock 4 wireless adapter over USB hidraw
          KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0666"

          # DualShock 4 Slim over USB hidraw
          KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666"

          # DualShock 4 over bluetooth hidraw
          KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0666"

          # DualShock 4 Slim over bluetooth hidraw
          KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0666"
        ''
        + (let
          mkRule = as: lib.concatStringsSep ", " as;
          mkRules = rs: lib.concatStringsSep "\n" rs;
        in
          mkRules [
            (mkRule [
              ''ACTION=="add|change"''
              ''SUBSYSTEM=="block"''
              ''KERNEL=="sd[a-z]"''
              ''ATTR{queue/rotational}=="1"''
              ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 41 /dev/%k"''
            ])
          ]);
    };

    systemd.sleep.extraConfig = ''
      HibernateDelaySec=2h
      AllowSuspend=yes
      AllowHibernation=yes
      AllowHybridSleep=yes
      AllowSuspendThenHibernate=yes
    '';

    services.thermald.enable = true;

    # services.auto-cpufreq.enable = true;
    # services.auto-cpufreq.settings = {
    #   battery = {
    #     governor = "powersave";
    #     turbo = "never";
    #   };
    #   charger = {
    #     governor = "performance";
    #     turbo = "auto";
    #   };
    # };
    systemd.services = {
      journal-resume = {
        description = "Service description here";
        wantedBy = ["post-resume.target"];
        after = ["post-resume.target"];
        script = ''
          echo "This should show up in the journal after resuming."
        '';
        serviceConfig.Type = "oneshot";
      };
    };
  };
}
