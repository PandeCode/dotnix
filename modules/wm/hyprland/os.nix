{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    ../wayland/os.nix
  ];

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      # package = pkgs.hyprland;
      # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };
  };
  environment = {
    systemPackages = [
      # inputs.hyprswitch.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
