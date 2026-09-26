{ config, lib, ... }:

let
  cfg = config.dotnix.i3;
in

{
  imports = [ ../x11/nixos.nix ];

  options.dotnix.i3.enable = lib.options.mkEnableOption "the i3 session";

  config = lib.modules.mkIf cfg.enable {
    dotnix.x11.enable = lib.modules.mkDefault true;

    services.xserver.windowManager.i3.enable = true;

    # polkit agents and other helpers live in libexec
    environment.pathsToLink = [ "/libexec" ];
  };
}
