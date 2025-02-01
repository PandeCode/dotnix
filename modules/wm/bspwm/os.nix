{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.bspwm;
in {
  imports = [../x/os.nix];
  options.bspwm.enable = lib.mkEnableOption "enable bspwm";

  config = lib.mkIf cfg.enable {
    x.enable = true;

    services.xserver.windowManager.bspwm = {
      enable = true;
    };
  };
}
