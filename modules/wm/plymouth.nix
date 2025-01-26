{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.plymouth;
in {
  options.plymouth.enable = lib.mkEnableOption "enable plymouth";

  config = lib.mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true;
        # theme = "SimulatedUniverse";
        theme = "PlymouthTheme-Cat";
        # theme = "chain";
        themePackages = with pkgs; [
          # (import ../../derivations/hsr-plymouth.nix {inherit stdenvNoCC fetchFromGitHub lib unstableGitUpdater;})
          (import ../../derivations/plymouth-theme-cat.nix {inherit stdenvNoCC fetchFromGitHub lib unstableGitUpdater;})
          # (import ../../derivations/plymouth-theme-chain.nix {
          #   inherit pkgs stdenvNoCC fetchFromGitHub lib unstableGitUpdater;
          #   config = {
          #     background = null;
          #     main = null;
          #     secondary = null;
          #   };
          # })
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
      loader.timeout = lib.mkForce 0;
    };
  };
}
