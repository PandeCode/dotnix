# services firefly runs for the other machines; each is off until enabled
{
  imports = [
    # keep-sorted start
    ./backup.nix
    ./dashboard.nix
    ./home.nix
    ./navidrome.nix
    ./notify.nix
    ./ntfy.nix
    # keep-sorted end
  ];
}
