{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}: let
  win_user = "pande";
in {
  imports = [
    ../../modules/programs/default.nix
    ../../modules/wm/hyprland/home.nix
    ../../modules/homes/stylix.nix
  ];

  hyprland_home.enable = true;

  stylix_home = {
    enable = true;
    dis.enable = true;
  };

  home = {
    inherit (osConfig.system) stateVersion;
  };
}
