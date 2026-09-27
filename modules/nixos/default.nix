{ inputs, ... }:

{
  imports = [
    ../generic
    ../profiles

    # keep-sorted start
    ./nix.nix
    ./users.nix
    # keep-sorted end

    # keep-sorted start
    ../hardware/amd.nix
    ../wm/i3/nixos.nix
    ../wm/niri/nixos.nix
    ../wm/river/nixos.nix
    ../wm/wayland/nixos.nix
    ../wm/x11/nixos.nix
    inputs.hermes.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.libys.nixosModules.default
    inputs.nix-index-database.nixosModules.default
    inputs.stylix.nixosModules.stylix
    # keep-sorted end
  ];
}
