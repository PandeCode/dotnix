{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.dwm;
in {
  imports = [../x/home.nix];
  options.dwm.enable = lib.mkEnableOption "enable dwm";

  config = lib.mkIf cfg.enable {
    x.enable = true;
  };
}
