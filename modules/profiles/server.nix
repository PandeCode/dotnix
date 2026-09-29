{ config, lib, ... }:

let
  never = "no";
in

{
  options.dotnix.profiles.server.enable = lib.options.mkEnableOption "staying up and reachable";

  config = lib.modules.mkIf config.dotnix.profiles.server.enable {
    dotnix.profiles.ssh.enable = lib.modules.mkDefault true;

    # a laptop server lives with its lid shut
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      IdleAction = "ignore";
    };

    systemd.sleep.settings.Sleep = {
      AllowSuspend = never;
      AllowHibernation = never;
      AllowHybridSleep = never;
      AllowSuspendThenHibernate = never;
    };
  };
}
