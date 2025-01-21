{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/programs/default.nix
    ../../modules/wm/hyprland/home.nix
    ../../modules/homes/stylix.nix
    ../../modules/gaming/default.nix
  ];

  hyprland_home.enable = true;
  spicetify.enable = true;
  wezterm.enable = true;
  gaming.enable = true;

  stylix_home = {
    enable = true;
    dis.enable = true;
  };

  home = {
    stateVersion = "24.11";
  };

  nixpkgs = {
    config.allowUnfree = true;
    # config.allowUnfreePredicate = pkg:
    #   builtins.elem (lib.getName pkg) [
    #     "google-chrome"
    #     "spotify"
    #     "obsidian"
    #   ];
  };
}
