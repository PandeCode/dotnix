{ inputs, ... }:

{
  imports = [
    # keep-sorted start
    (import ../wm/river/home.nix { inherit (inputs.nixutils.lib) toZON; })
    ../wm/i3/home.nix
    ../wm/niri/home.nix
    ../wm/shared.nix
    ../wm/wayland/home.nix
    ../wm/x11/home.nix
    # keep-sorted end
  ];
}
