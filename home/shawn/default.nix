{
  imports = [
    ../../modules/home

    # keep-sorted start
    ./apps.nix
    ./browsers.nix
    ./desktop.nix
    ./git.nix
    ./i3.nix
    ./media.nix
    ./niri.nix
    ./river.nix
    ./shell.nix
    ./theme.nix
    ./tools.nix
    ./wayland.nix
    ./wm.nix
    ./x11.nix
    # keep-sorted end
  ];

  # the release this home was first set up with, not the current one
  home.stateVersion = "24.11";
}
