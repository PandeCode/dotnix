{
  pkgs,
  lib,
  ...
}: {
  boot = {
    plymouth = {
      enable = true;
      theme = "PlymouthTheme-Custom";
      # theme = "PlymouthTheme-Cat";
      # extraConfig = /* ini */ '' DeviceScale=1 '';

      themePackages = let
        inherit (((import ../../derivations/default.nix) pkgs.callPackage)) plymouth-theme-custom;
        # inherit (((import ../../derivations/default.nix) pkgs.callPackage)) plymouth-theme-cat;
      in [
        # plymouth-theme-cat
        plymouth-theme-custom
      ];
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = lib.mkForce 4;
  };
}
