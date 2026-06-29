{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.xmonad;
in {
  imports = [../x/home.nix];
  options.xmonad.enable = lib.mkEnableOption "enable xmonad";

  config = lib.mkIf cfg.enable {
    x.enable = true;
  };
}
