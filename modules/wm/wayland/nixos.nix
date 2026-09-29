{ config, lib, ... }:

{
  options.dotnix.wayland.enable = lib.options.mkEnableOption "the basics for wayland sessions";

  config = lib.modules.mkIf config.dotnix.wayland.enable {
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
    programs.xwayland.enable = true;

    # electron and chromium apps use wayland instead of xwayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
