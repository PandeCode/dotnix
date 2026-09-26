# what my wayland sessions use, ported from old/modules/wm/wayland/*.nix,
# old/modules/programs/swaync.nix and old/modules/programs/eww.nix
{ pkgs, ... }:

{
  services = {
    hyprpolkitagent.enable = true;

    swaync = {
      enable = true;
      settings = builtins.fromJSON (builtins.readFile ../../config/swaync/config.json);
    };
  };

  programs.eww = {
    enable = true;
    yuckConfig = builtins.readFile ../../config/eww/eww.yuck;
    scssConfig = builtins.readFile ../../config/eww/eww.scss;
  };

  xdg.configFile = {
    "sunsetr/sunsetr.toml".source = ../../config/sunsetr/sunsetr.toml;
    "sunsetr/presets/day/sunsetr.toml".source = ../../config/sunsetr/presets/day/sunsetr.toml;
  };

  home.packages = with pkgs; [
    awww
    brightnessctl
    cliphist
    gowall
    grim
    hyprpicker
    pamixer
    playerctl
    slurp
    sunsetr
    swaybg
    translate-shell
    wayvnc
    wdisplays
    wev
    wl-clipboard
    wlprop
    wmctrl
    woomer
    xdg-utils
  ];
}
