{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.spicetify;
in {
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];
  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    # theme = lib.mkForce spicePkgs.themes.hazy;
    enable = true;
    enabledCustomApps = with spicePkgs.apps; [
      newReleases
      lyricsPlus
      marketplace
      ncsVisualizer
      {
        src = pkgs.fetchFromGitHub {
          owner = "Pithaya";
          repo = "spicetify-apps-dist";
          rev = "ab6d4440bcbf0ad0060c5a19581b43605720f113";
          hash = "sha256-4P8wHBvjzjRvzhBTU8zVD+2QCZAw5A9BgmYiG59UcQA=";
        };
        name = "eternal-jukebox";
      }
    ];
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
    ];
  };
}
