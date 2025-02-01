{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.i3;
in {
  imports = [../x/os.nix];
  options.i3.enable = lib.mkEnableOption "enable i3";

  config = lib.mkIf cfg.enable {
    x.enable = true;
    environment.pathsToLink = ["/libexec"]; # links /libexec from derivations to /run/current-system/sw
    services.xserver.windowManager.i3.enable = true;
  };
}
