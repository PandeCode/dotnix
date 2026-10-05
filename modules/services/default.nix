# services firefly runs for the other machines; each is off until enabled
{ config, lib, ... }:

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
    ./ntfy.nix
    ./pdf.nix
    ./photos.nix
    ./read.nix
    ./search.nix
    ./syncthing.nix
    ./theme.nix
    # keep-sorted end
  ];

  # the ones that need a password skip themselves without it; say so
  warnings =
    lib.attrsets.mapAttrsToList
      (
        name: _:
        "dotnix.services.${name} is enabled without a passwordFile, so what needs the password is skipped"
      )
      (
        lib.attrsets.filterAttrs (
          _: s: s.enable or false && s ? passwordFile && s.passwordFile == null
        ) config.dotnix.services
      );
}
