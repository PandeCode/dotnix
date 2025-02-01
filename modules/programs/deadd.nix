{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.deadd;
in {
  options.deadd.enable = lib.mkEnableOption "enable deadd";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.deadd-notification-center];

    # services.deadd-notification-center = {

    # }
  };
}
