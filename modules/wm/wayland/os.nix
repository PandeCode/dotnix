{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.wayland;
in {
  imports = [../os.nix];

  xdg.portal.wlr.enable = lib.mkForce true;

  services.gnome = {
    gnome-keyring.enable = true;
  };
  security.polkit.enable = true;

  programs = {
    xwayland.enable = lib.mkForce true;
    ydotool = {
      enable = true;
      group = "users";
    };
  };

  hardware = {
    graphics.enable = true;
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XKB_DEFAULT_OPTIONS = "caps:escape";
    };

    systemPackages = with pkgs; [
      brightnessctl
      cliphist
      grim
      grimblast
      pamixer
      playerctl
      slurp
      translate-shell
      wl-clipboard
      woomer
      xdg-utils

      swww # linux-wallpaperengine hyprpaper swaybg wpaperd mpvpaper
      gowall
      swaybg
    ];
  };
}
