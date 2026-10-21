{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotnix.profiles.boot;
in

{
  options.dotnix.profiles.boot = {
    enable = lib.options.mkEnableOption "grub for UEFI, themed, next to other systems";

    scale = lib.options.mkOption {
      type = lib.types.number;
      default = 1;
      example = 1.5;
      description = "Size of the boot menu: 1 for 1080p, 1.5 for 1600p, 2 for 4k.";
    };
  };

  config = lib.modules.mkIf cfg.enable {
    boot.loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 20;
        theme = pkgs.grub-foundry-theme.override {
          inherit (cfg) scale;
          # the game's version string in the corner
          corner = "GRUB ${config.boot.loader.grub.package.version} (build ${config.networking.hostName}, ${pkgs.stdenv.hostPlatform.system})";
        };
      };
    };
  };
}
