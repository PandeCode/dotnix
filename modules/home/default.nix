# home-manager modules, always imported, each off until enabled
{ inputs, ... }:

{
  imports = [
    # keep-sorted start
    (import ../wm/river/home.nix { inherit (inputs.nixutils.lib) toZON; })
    ../wm/niri/home.nix
    ../wm/shared.nix
    ../wm/wayland/home.nix
    # keep-sorted end
  ];
}
