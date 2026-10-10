{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.modules) mkDefault mkForce mkIf;

  cfg = config.dotnix.profiles.laptop;

  battery-low = pkgs.writeShellApplication {
    name = "battery-low";
    runtimeInputs = [ pkgs.libnotify ];
    text = builtins.readFile ./scripts/battery-low.sh;
  };
in

{
  options.dotnix.profiles.laptop = {
    enable = lib.options.mkEnableOption "my laptop power settings";
    # amd laptops last longer on power-profiles-daemon, see nixos-hardware's framework amd module
    power = lib.options.mkOption {
      type = lib.types.enum [
        "tlp"
        "ppd"
      ];
      default = "tlp";
      description = "What manages CPU power: TLP, or power-profiles-daemon.";
    };
  };

  config = mkIf cfg.enable {
    powerManagement = {
      enable = true;
      powertop.enable = true;
    };

    hardware.acpilight.enable = true;

    services = {
      upower.enable = true;

      power-profiles-daemon.enable = mkForce (cfg.power == "ppd");

      tlp = {
        enable = cfg.power == "tlp";
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

          # https://linrunner.de/tlp/faq/battery.html#how-to-choose-good-battery-charge-thresholds
          # both indexes: the battery shows up as BAT0 or BAT1
          START_CHARGE_THRESH_BAT0 = 75;
          STOP_CHARGE_THRESH_BAT0 = 80;
          START_CHARGE_THRESH_BAT1 = 75;
          STOP_CHARGE_THRESH_BAT1 = 80;
        };
      };

      logind.settings.Login = builtins.mapAttrs (_: mkDefault) {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "lock";
        HandleLidSwitchDocked = "ignore";
      };
    };

    systemd = {
      sleep.settings.Sleep = builtins.mapAttrs (_: mkDefault) {
        HibernateDelaySec = "2h";
        AllowSuspend = "yes";
        AllowHibernation = "yes";
        AllowHybridSleep = "yes";
        AllowSuspendThenHibernate = "yes";
      };

      user = {
        services.battery-low = {
          description = "Warn when the battery is almost empty";
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.meta.getExe battery-low;
          };
        };

        timers.battery-low = {
          wantedBy = [ "timers.target" ];
          timerConfig.OnCalendar = "minutely";
        };
      };
    };

    environment.systemPackages = [ pkgs.acpi ];
  };
}
