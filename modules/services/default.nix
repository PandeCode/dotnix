# services firefly runs for the other machines; each is off until enabled
{
  imports = [
    # keep-sorted start
    ./home.nix
    ./navidrome.nix
    ./notify.nix
    ./ntfy.nix
    # keep-sorted end
  ];
}
