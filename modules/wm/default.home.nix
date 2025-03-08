{sharedConfig, ...}: let
  ifl = i: l: (
    if i
    then [l]
    else []
  );
  mk = name: ifl sharedConfig.wms.${name}.enable ../../modules/wm/${name}/home.nix;
  mkAll = l: builtins.concatLists (map (n: mk n) l);
in {
  imports = mkAll [
    "hyprland"
    "niri"
    "sway"
    "i3"
  ];

  # imports =
  #   (ifl sharedConfig.wms.hyprland.enable ../../modules/wm/hyprland/home.nix)
  #   ++ (ifl sharedConfig.wms.sway.enable ../../modules/wm/sway/home.nix)
  #   ++ (ifl sharedConfig.wms.i3.enable ../../modules/wm/i3/home.nix)
  #   # ++ (ifl sharedConfig.wms.dwm.enable ../../modules/wm/dwm/home.nix)
  #   # ++ (ifl sharedConfig.wms.awesomewm.enable ../../modules/wm/awesomewm/home.nix)
  #   # ++ (ifl sharedConfig.wms.bspwm.enable ../../modules/wm/bspwm/home.nix)
  #   # ++ (ifl sharedConfig.wms.xmonad.enable ../../modules/wm/xmonad/home.nix)
  #   ++ (ifl sharedConfig.wms.niri.enable ../../modules/wm/niri/home.nix);
}
