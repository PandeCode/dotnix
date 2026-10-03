# services firefly runs for the other machines; each is off until enabled
{
  imports = [
    # keep-sorted start
    ./backup.nix
    ./beszel.nix
    ./dashboard.nix
    ./forgejo.nix
    ./home.nix
    ./navidrome.nix
    ./notify.nix
    ./ntfy.nix
    ./search.nix
    # keep-sorted end
  ];
}
