{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.plymouth;
  theme = pkgs.mkDerivation {
    name = "theme";
    src = pkgs.fetchFromGitHub {
      owner = "ohaiibuzzle";
      repo = "Plymouth-SimulatedUniverse";
      rev = "c990d0a59c41def5adbffc3995c5d59c30843c77";
      sha256 = "ErLBgxp8WB+PhyG7YFs8IaQN7V1+N4afx6OwkTwIUgA=";
    };
    installPhase = ''
    '';
  };
in {
  options.plymouth.enable = lib.mkEnableOption "enable plymouth";

  config = lib.mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true;
        theme = "breeze";
        # theme = "rings";
        # themePackages = with pkgs; [
        #   # By default we would install all themes ~500Mb+
        #   (adi1090x-plymouth-themes.override {
        #     selected_themes = ["rings"];
        #   })
        # ];
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
