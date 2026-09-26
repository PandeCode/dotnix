# what every x11 session needs on the system side. x11 window managers turn
# this on
{ config, lib, ... }:

{
  options.dotnix.x11.enable = lib.options.mkEnableOption "the basics for x11 sessions";

  config = lib.modules.mkIf config.dotnix.x11.enable {
    services.xserver = {
      enable = true;
      xkb.layout = lib.modules.mkDefault "us";
    };
  };
}
