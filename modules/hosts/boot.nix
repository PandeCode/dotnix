{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.boot_opts;
in {
  options.boot_opts.enable = lib.mkEnableOption "enable boot_opts";

  config = lib.mkIf cfg.enable {
    # swapDevices = [ {device = swap;} ];
    boot = {
      # resumeDevice = swap;
      plymouth = {
        enable = true;
        theme = "rings";
        themePackages = with pkgs; [
          # By default we would install all themes
          (adi1090x-plymouth-themes.override {
            selected_themes = ["rings"];
          })
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
      loader.timeout = 0;
    };
  };
}
