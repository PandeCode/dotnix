{
  pkgs,
  lib,
  config,
  inputs,
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
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
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

        (
          writeShellScriptBin "rofi-wifi-menu" (fetchurl {
            url = "https://raw.githubusercontent.com/zbaylin/rofi-wifi-menu/refs/heads/master/rofi-wifi-menu.sh";
            sha256 = "0gilv2q4l7synn1labwzw3bm4xy4h1z2l7kh1jhjyfxn3xpx7fnc";
          })
        )
      ];
    };
  };
}
