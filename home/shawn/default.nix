{
  imports = [
    ../../modules/home

    # keep-sorted start
    ./i3.nix
    ./niri.nix
    ./river.nix
    ./wm.nix
    ./x11.nix
    # keep-sorted end
  ];

  # the release this home was first set up with, not the current one
  home.stateVersion = "24.11";
}
