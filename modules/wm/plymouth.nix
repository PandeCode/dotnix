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

      themePackages = [
        # (pkgs.callPackage ../../derivations/plymouth-theme-cat.nix {})
        (pkgs.callPackage ../../derivations/plymouth-theme-custom.nix {})
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
