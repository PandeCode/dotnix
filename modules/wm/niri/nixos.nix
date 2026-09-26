{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotnix.niri;
in
{
  options.dotnix.niri = {
    enable = lib.mkEnableOption "niri session";
    package = lib.mkPackageOption pkgs "niri" { };
  };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      inherit (cfg) package;
    };
  };
}
