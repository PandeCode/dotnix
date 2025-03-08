# This file is for defining targets
{
  pkgs,
  lib,
  config,
  ...
}: let
in {
  config = {
    stylix =
      (import ../stylix/common.nix {inherit pkgs;}).stylix
      // {
        targets = {
          chromium.enable = true; # GUI
          console.enable = true;
          feh.enable = true;
          fish.enable = true;

          gnome-text-editor.enable = true;
          gnome.enable = true;
          grub.enable = true;
          grub.useImage = true;

          gtk.enable = true;
          kmscon.enable = true;
          nixos-icons.enable = true;

          regreet.enable = false;
          lightdm.enable = false;
          nixvim.enable = false;
          plymouth.enable = false;
        };
      };
  };
}
