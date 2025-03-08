{sharedConfig, ...}: let
  ifl = i: l: (
    if i
    then [l]
    else []
  );
in {
  imports =
    (ifl sharedConfig.wms.hyprland.enable ../../modules/wm/hyprland/os.nix)
    ++ (ifl sharedConfig.wms.sway.enable ../../modules/wm/sway/os.nix)
    ++ (ifl sharedConfig.wms.i3.enable ../../modules/wm/i3/os.nix)
    ++ (ifl sharedConfig.wms.niri.enable ../../modules/wm/niri/os.nix);

  # awesomewm.enable = sharedConfig.awesomewm.enable;
  # bspwm.enable = sharedConfig.bspwm.enable;
  # dwm.enable = true;
  # xmonad.enable = sharedConfig.xmonad.enable;
}
