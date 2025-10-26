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
    "river"
    "dwm"
  ];
}
