{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.hyprland_os;
in {
  options.hyprland_os.enable = lib.mkEnableOption "enable hyprland os level";

  config = lib.mkIf cfg.enable {
    programs = {
      hyprland = {
        enable = true;
        xwayland.enable = true;
      };
    };
    hardware = {
      graphics.enable = true;
    };

    environment = {
      sessionVariables = {
        # WLR_NO_HARDWARE_CURSORS = "1"; # invisible cursor protection
        NIXOS_OZONE_WL = "1";
      };

      systemPackages = with pkgs; [
        rofi-wayland
        bemenu
        kitty

        waybar

        swww
        # linux-wallpaperengine
        # hyprpaper
        # swaybg
        # wpaperd
        # mpvpaper
      ];
    };
  };
}
