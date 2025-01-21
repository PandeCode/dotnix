{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.dunst;
in {
  options.dunst.enable = lib.mkEnableOption "enable dunst";

  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
    };
  };
}
