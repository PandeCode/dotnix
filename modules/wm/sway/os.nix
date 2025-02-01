{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.sway;
in {
  imports = [../wayland/os.nix];
  options.sway.enable = lib.mkEnableOption "enable sway";

  config = lib.mkIf cfg.enable {
    wayland.enable = true;

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };
}
