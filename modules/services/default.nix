# services firefly runs for the other machines; each is off until enabled
{
  imports = [
    # keep-sorted start
    ./atuin.nix
    ./backup.nix
    ./beszel.nix
    ./dashboard.nix
    ./files.nix
    ./forgejo.nix
    ./home.nix
    ./navidrome.nix
    ./notify.nix
    ./ntfy.nix
    ./search.nix
    ./syncthing.nix
    # keep-sorted end
  ];
}
