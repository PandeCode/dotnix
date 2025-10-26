{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
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

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XKB_DEFAULT_OPTIONS = "caps:escape";
    };

    systemPackages = with pkgs; [
      # inputs.charon-shell.packages.${pkgs.system}.default
      # inputs.obolc.packages.${pkgs.system}.default

      brightnessctl
      cliphist

      (grim.overrideAttrs (oldAttrs: {
        src = fetchFromGitHub {
          owner = "eriedaberrie";
          repo = "grim-hyprland";
          rev = "4a3d6f5b87b01e92c404b9393b79057b85f58c60";
          sha256 = "sha256-4m2QFT8mY6CM3YSebMJhd/kJWaRxTYOS/nvAs2TaIQs=";
        };
        buildInputs =
          oldAttrs.buildInputs
          ++ [
            wayland-scanner
            hyprwayland-scanner
          ];
      }))

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

      wmctrl
      wev
    ];
  };
}
