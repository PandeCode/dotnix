{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.spicetify;
in {
  options.spicetify.enable = lib.mkEnableOption "enable spicetify";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.spotify];
    programs.spicetify = let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle # shuffle+ (special characters are sanitized out of extension names)
      ];
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };
  };
}
