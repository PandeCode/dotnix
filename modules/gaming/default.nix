{
  pkgs,
  lib,
  ...
}:
# let
# nixpkgs-olympus = inputs.nixpkgs-olympus.legacyPackages.${pkgs.system};
# nixpkgs-sgdboop = inputs.nixpkgs-sgdboop.legacyPackages.${pkgs.system};
# in
{
  # imports = [./mangohud];
  options.gaming.enable = lib.mkEnableOption "enable gaming packages and configuration.";

  config = {
    home.packages = with pkgs; let
      a = [
        (prismlauncher.override {
          # use temurin, they're better
          jdks = [
            temurin-jre-bin-8
            temurin-jre-bin-17
            temurin-jre-bin-21
          ];
        })
        osu-lazer-bin
        lutris
        gamescope
        heroic
        cemu
        wine-staging

        linux-wallpaperengine
      ];
    in [];
    # ++ [
    #   nixpkgs-olympus.olympus
    #   nixpkgs-sgdboop.sgdboop
    # ]
  };
}
