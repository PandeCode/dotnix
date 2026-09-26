{ inputs, ... }:

{
  imports = [
    ../generic

    # keep-sorted start
    ./nix.nix
    ./users.nix
    # keep-sorted end

    # always imported, each is off until a host enables it
    # keep-sorted start
    ../wm/i3/nixos.nix
    ../wm/niri/nixos.nix
    ../wm/river/nixos.nix
    ../wm/wayland/nixos.nix
    ../wm/x11/nixos.nix
    inputs.hermes.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.libys.nixosModules.default
    # keep-sorted end
  ];
}
