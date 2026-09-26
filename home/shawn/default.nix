{
  imports = [
    ../../modules/home

    # keep-sorted start
    ./desktop.nix
    ./i3.nix
    ./niri.nix
    ./river.nix
    ./screenshot.nix
    ./theme.nix
    ./wayland.nix
    ./wm.nix
    ./x11.nix
    # keep-sorted end
  ];

  # the release this home was first set up with, not the current one
  home.stateVersion = "24.11";
}
