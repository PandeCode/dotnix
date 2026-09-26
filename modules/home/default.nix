# home-manager modules, always imported, each off until enabled
{
  imports = [
    # keep-sorted start
    ../wm/niri/home.nix
    ../wm/shared.nix
    ../wm/wayland/home.nix
    # keep-sorted end
  ];
}
