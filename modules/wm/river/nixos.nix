# rill, the window manager, starts from ~/.config/river/init (home.nix)
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotnix.river;
in

{
  imports = [ ../wayland/nixos.nix ];

  options.dotnix.river = {
    enable = lib.options.mkEnableOption "the river session";
    package = lib.options.mkPackageOption pkgs "river" { };
  };

  config = lib.modules.mkIf cfg.enable {
    dotnix.wayland.enable = lib.modules.mkDefault true;

    environment.systemPackages = [ cfg.package ];
    services.displayManager.sessionPackages = [ cfg.package ];

    # screen sharing through the wlroots portal, the rest through gtk
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.river.default = [
        "wlr"
        "gtk"
      ];
    };
  };
}
