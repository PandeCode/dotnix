{ config, lib, ... }:

{
  # the apps themselves install in the home, which reads this
  options.dotnix.profiles.apps.enable = lib.options.mkEnableOption "my everyday apps";

  config = lib.modules.mkIf config.dotnix.profiles.apps.enable {
    programs.kdeconnect.enable = true;
  };
}
