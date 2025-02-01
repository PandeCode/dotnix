{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.wayland;
in {
  imports = [../os.nix];

  options.wayland.enable = lib.mkEnableOption "enable wayland";

  config = lib.mkIf cfg.enable {
    wm.enable = true;

    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;

    programs = {
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
        (import ../../../derivations/notify-send-py.nix {inherit lib pkgs;})
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
  };
}
