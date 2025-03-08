{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.hyprland;
in {
  imports = [
    ../wayland/os.nix
  ];

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
      package = pkgs.hyprland;
      # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };
  };
  environment = {
    systemPackages = with pkgs; [
      inputs.hyprswitch.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
