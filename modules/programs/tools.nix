{
  pkgs,
  lib,
  config,
  # utils,
  ...
}: let
  cfg = config.tools;
in {
  options.tools.enable = lib.mkEnableOption "enable tools";

  config = lib.mkIf cfg.enable {
    home.packages =
      # with utils;
      [
        # (mkToolC "strdist")
        # (mkToolRust "zellij_ping")
      ];
  };
}
