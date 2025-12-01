{
  pkgs,
  lib,
  config,
  ...
}: {
  services.tlp.enable = true;
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
  services.ananicy = {
    enable = false;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  powerManagement = {
    enable = false;
    # cpuFreqGovernor = "performance";
    powertop.enable = true;
    # scsiLinkPolicy = "max_performance";
    # "ondemand", "powersave", "performance"
  };

  # services = {
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
  # };

  systemd = {
    sleep.extraConfig = ''
      HibernateDelaySec=2h
      AllowSuspend=yes
      AllowHibernation=yes
      AllowHybridSleep=yes
      AllowSuspendThenHibernate=yes
    '';
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
}
