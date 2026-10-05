# services firefly runs for the other machines; each is off until enabled
{
  imports = [
    # keep-sorted start
    ./atuin.nix
    ./backup.nix
    ./beszel.nix
    ./books.nix
    ./builder.nix
    ./cache.nix
    ./dashboard.nix
    ./dav.nix
    ./docs.nix
    ./files.nix
    ./firefox.nix
    ./forgejo.nix
    ./home.nix
    ./money.nix
    ./navidrome.nix
    ./news.nix
    ./notify.nix
    ./pdf.nix
    ./ntfy.nix
    ./photos.nix
    ./read.nix
    ./search.nix
    ./syncthing.nix
    ./theme.nix
    # keep-sorted end
  ];
}
