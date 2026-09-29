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
  imports = [ ../wayland/nixos.nix ];

  options.dotnix.niri = {
    enable = lib.options.mkEnableOption "the niri session";
    package = lib.options.mkPackageOption pkgs "niri" { };
  };

  config = lib.modules.mkIf cfg.enable {
    dotnix.wayland.enable = lib.modules.mkDefault true;

    programs.niri = {
      enable = true;
      inherit (cfg) package;
    };

    # niri starts it on demand when an x11 app connects
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
