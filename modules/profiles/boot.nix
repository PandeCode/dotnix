{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.dotnix.profiles.boot.enable =
    lib.options.mkEnableOption "grub for UEFI, themed, next to other systems";

  config = lib.modules.mkIf config.dotnix.profiles.boot.enable {
    boot.loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 20;
        theme = pkgs.hyperfluent-grub-theme;
      };
    };
  };
}
