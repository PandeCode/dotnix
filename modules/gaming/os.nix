{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.gaming_os;
in {
  options.gaming_os.enable = lib.mkEnableOption "enable gaming_os";

  config = lib.mkIf cfg.enable {
    programs = {
      steam.enable = true;
      gamemode.enable = true;
    };
  };
}
