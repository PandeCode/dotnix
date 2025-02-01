{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.x;
in {
  options.x.enable = lib.mkEnableOption "enable x";

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };
}
