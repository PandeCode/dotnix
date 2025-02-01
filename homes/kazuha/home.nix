{sharedConfig, ...}: {
  imports = [
    ../../modules/programs/default.nix

    ../../modules/wm/hyprland/home.nix
    ../../modules/wm/sway/home.nix

    ../../modules/wm/i3/home.nix

    ../../modules/wm/awesomewm/home.nix
    ../../modules/wm/bspwm/home.nix
    ../../modules/wm/dwm/home.nix
    ../../modules/wm/xmonad/home.nix

    ../../modules/homes/stylix.nix
    ../../modules/gaming/home.nix
  ];

  hyprland.enable = sharedConfig.hyprland.enable;
  sway.enable = sharedConfig.sway.enable;

  awesomewm.enable = sharedConfig.awesomewm.enable;
  bspwm.enable = sharedConfig.bspwm.enable;
  dwm.enable = sharedConfig.dwm.enable;
  i3.enable = sharedConfig.i3.enable;
  xmonad.enable = sharedConfig.xmonad.enable;

  spicetify.enable = true;
  wezterm.enable = true;

  gaming.enable = sharedConfig.gaming.enable;

  stylix_home = {
    enable = true;
    dis.enable = true;
  };

  home .stateVersion = "24.11";
  nixpkgs = {config.allowUnfree = true;};
  services.kdeconnect.enable = true;
}
