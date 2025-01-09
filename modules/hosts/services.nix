{
  pkgs,
  lib,
  ...
}: {
  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;

        # Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 20; # 40 and bellow it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 90; # 80 and above it stops charging
      };
    };
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
    udev.extraRules = let
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
      ];
  };

  # systemd.sleep.extraConfig = ''
  #   HibernateDelaySec=2h
  # '';

  systemd.services = {
    autostart = {
      description = "Backlight and kernel settings configuration";
      serviceConfig = {
        User = "root";
        ExecStart = ''
          sudo -E chmod 777 /sys/class/backlight/intel_backlight/brightness
          sudo sysctl dev.i915.perf_stream_paranoid=0
          sudo sysctl -w abi.vsyscall32=0
        '';
        WantedBy = ["multi-user.target"];
      };
    };

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
}
