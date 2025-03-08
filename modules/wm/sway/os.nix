{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.sway;
in {
  imports = [../wayland/os.nix];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
}
