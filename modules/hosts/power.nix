{
  pkgs,
  lib,
  config,
  ...
}: {
  powerManagement = {
    enable = true;
    # cpuFreqGovernor = "performance";
    powertop.enable = true;
    # scsiLinkPolicy = "max_performance";
    # "ondemand", "powersave", "performance"
  };

  services = {
    power-profiles-daemon.enable = lib.mkForce false;
    upower = {enable = true;};

    logind.settings.Login = {
      HandleLidSwitch = "poweroff";
      HandleLidSwitchExternalPower = "lock";
      HandleLidSwitchDocked = "ignore";
    };
    auto-cpufreq = {
      enable = false;
      settings = {
        # https://github.com/AdnanHodzic/auto-cpufreq/blob/v3.1.0/auto-cpufreq.conf-example
        battery = {
          governor = "powersave";
          turbo = "never";

          # enable thresholds true or false
          enable_thresholds = true;
          # start threshold (0 is off ) can be 0-99
          start_threshold = 40;
          # stop threshold (100 is off) can be 1-100
          stop_threshold = 80;
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

    tlp = {
      enable = true; # try auto-cpufreq

      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;

        START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
      };
    };
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
    # thermald.enable = true;
    # auto-cpufreq = {
    #   enable = true;
    #   settings = {
    #     battery = {
    #       governor = "powersave";
    #       turbo = "never";
    #     };
    #     charger = {
    #       governor = "performance";
    #       turbo = "auto";
    #     };
    #   };
    # };
  };

  systemd = {
    sleep.settings.Sleep = {
      HibernateDelaySec = "2h";
      AllowSuspend = "yes";
      AllowHibernation = "yes";
      AllowHybridSleep = "yes";
      AllowSuspendThenHibernate = "yes";
    };
    services = {
      syncthing.environment.STNODEFAULTFOLDER = "true";
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

  # https://gist.github.com/cafkafk/deac78b5cb821049ee03e9b55f898d07
  systemd.user.services."battery-low" = {
    enable = true;
    description = "Notify user if battery is below 10%";
    partOf = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart =
        pkgs.writeShellScript "battery-low-notification"
        ''
          if (( 10 >= $(${pkgs.lib.getExe pkgs.acpi} -b | head -n 1 | ${pkgs.lib.getExe pkgs.ripgrep} -o "\d+%" | ${pkgs.lib.getExe pkgs.ripgrep} -o "\d+")));
          then ${pkgs.lib.getExe pkgs.pkgs.libnotify} --urgency=critical "low battery" "$(${pkgs.lib.getExe pkgs.acpi} -b | head -n 1 | ${pkgs.lib.getExe pkgs.ripgrep} -o "\d+%")";
          else echo; fi;
        '';
    };
  };
  systemd.user.timers."battery-low" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      # Every Minute
      OnCalendar = "*-*-* *:*:00";
      Unit = "battery-low.service";
    };
  };
}
