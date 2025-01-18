# This file is for defining targets
{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.stylix_os;
  boot = lib.mkIf cfg.boot.enable true;
  never = lib.mkForce false;
in {
  options.stylix_os = {
    enable = lib.mkEnableOption "Enable Stylix for OS";
    boot.enable = lib.mkEnableOption "enable boot styles (sddm, bootscreen, ..)";
  };

  config = lib.mkIf cfg.enable {
    stylix =
      (import ../stylix/common.nix {inherit pkgs;}).stylix
      // {
        targets = {
          console.enable = true;
          feh.enable = true;
          fish.enable = true;

          gtk.enable = true;
          nixos-icons.enable = true;

          gnome-text-editor.enable = never;
          gnome.enable = never;
          nixvim.enable = never;

          grub.enable = boot;
          grub.useImage = boot;

          kmscon.enable = boot;

          chromium.enable = boot; # GUI

          plymouth.enable = false; # i handle this
          # plymouth.logo = boot;
          # plymouth.logoAnimated = boot;

          regreet.enable = boot;
          lightdm.enable = boot;
        };
      };
  };
}
