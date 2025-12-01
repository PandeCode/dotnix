{
  pkgs,
  sharedConfig,
  ...
}: {
  config = {
    stylix =
      (import ../stylix/common.nix {inherit pkgs sharedConfig;}).stylix
      // {
        targets = {
          chromium.enable = true; # GUI
          console.enable = true;
          feh.enable = true;
          fish.enable = true;

          gnome-text-editor.enable = true;
          gnome.enable = true;
          grub.enable = false;
          grub.useWallpaper = true;

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
