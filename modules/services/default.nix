# services firefly runs for the other machines; each is off until enabled
{
  imports = [
    # keep-sorted start
    ./atuin.nix
    ./backup.nix
    ./beszel.nix
    ./builder.nix
    ./cache.nix
    ./dashboard.nix
    ./dav.nix
    ./files.nix
    ./forgejo.nix
    ./home.nix
    ./navidrome.nix
    ./news.nix
    ./notify.nix
    ./ntfy.nix
    ./read.nix
    ./search.nix
    ./syncthing.nix
    ./theme.nix
    # keep-sorted end
  ];
}
