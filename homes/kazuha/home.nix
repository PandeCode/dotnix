{
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ../../modules/programs/default.nix
    ../../modules/wm/hyprland/home.nix
    ../../modules/homes/stylix.nix
    ../../modules/gaming/home.nix
  ];

  hyprland_home.enable = true;
  spicetify.enable = true;
  wezterm.enable = true;

  programs.btop.enable = true;

  gaming.enable = osConfig.config.gaming_os.enable or false;

  stylix_home = {
    enable = true;
    dis.enable = true;
  };

  home = {
    stateVersion = "24.11";
    packages = with pkgs; [
      obsidian
      vesktop
      vscodium
    ];
  };

  nixpkgs = {
    config.allowUnfree = true;
  };

  services.kdeconnect.enable = true;
}
