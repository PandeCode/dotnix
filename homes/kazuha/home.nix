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
  gaming.enable = false;

  stylix_home = {
    enable = true;
    dis.enable = true;
  };

  home = {
    stateVersion = "24.11";
    packages = with pkgs; [
      obsidian
      discord
    ];
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
