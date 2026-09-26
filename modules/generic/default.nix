# everything that works in every class: nixos, wsl, iso and darwin
{
  imports = [
    # keep-sorted start
    ./home-manager.nix
    ./nix.nix
    ./options.nix
    # keep-sorted end
  ];
}
