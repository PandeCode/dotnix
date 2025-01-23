{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.bitwarden;
in {
  options.bitwarden.enable = lib.mkEnableOption "enable bitwarden";

  config = lib.mkIf cfg.enable {
    programs = {
      rbw = {
        enable = true;

        settings = {
          email = "";
          lock_timeout = 3600;
          pinentry = "";
        };
      };
    };

    home.packages = with pkgs; [
    ];
  };
}
