{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.bspwm;
in {
  imports = [../x/home.nix];
  options.bspwm.enable = lib.mkEnableOption "enable bspwm";

  config = lib.mkIf cfg.enable {
    x.enable = true;

    xsession.windowManager.bspwm = {
      enable = true;
      settings = {
        border_width = 2;
        gapless_monocle = true;
        split_ratio = 0.52;
      };
    };
  };
}
