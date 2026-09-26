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
    ../wm/niri/nixos.nix
    ../wm/wayland/nixos.nix
    inputs.hermes.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.libys.nixosModules.default
    # keep-sorted end
  ];
}
