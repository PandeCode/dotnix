{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.astal;
  inherit (inputs) astal;
  mkAstal = name:
    astal.lib.mkLuaPackage {
      inherit pkgs;
      name = "astal-${name}";
      src = ../../config/astal/${name};
      extraPackages = [
        astal.packages.${pkgs.stdenv.hostPlatform.system}.battery
        pkgs.dart-sass
      ];
    };
in {
  options.astal.enable = lib.mkEnableOption "enable astal";

  config = lib.mkIf cfg.enable {
    home.packages = with astal.packages.${pkgs.stdenv.hostPlatform.system}; [
      default
      battery
      io
      # astal3
      astal4
      apps
      auth
      battery
      bluetooth
      cava
      greet
      hyprland
      mpris
      network
      notifd
      powerprofiles
      river
      tray
      wireplumber

      pkgs.dart-sass

      # (mkAstal "notifications")
      # (mkAstal        "launcher")
      # (mkAstal        "player")
      (mkAstal "bar")
    ];
  };
}
