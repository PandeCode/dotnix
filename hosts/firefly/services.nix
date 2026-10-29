# what firefly serves; its address and passwords are private
{ config, ... }:

let
  feeds = import ../../home/shawn/feeds.nix;
in

{
  dotnix = {
    services = {
      agda.enable = true;
      atuin.enable = true;
      beszel.enable = true;
      books.enable = true;
      builder.enable = true;
      cache.enable = true;
      code.enable = true;
      compute.enable = true;
      config.enable = true;
      dashboard = {
        enable = true;
        feeds = map (feed: feed.url) feeds;
      };
      dav.enable = true;
      docs.enable = true;
      draw.enable = true;
      files.enable = true;
      firefox.enable = true;
      forgejo = {
        enable = true;
        runner = true;
      };
      money.enable = true;
      navidrome.enable = true;
      news = {
        enable = true;
        inherit feeds;
      };
      ntfy.enable = true;
      office.enable = true;
      pdf.enable = true;
      photos.enable = true;
      read.enable = true;
      # the i3 session, to pick up where you left off from kazuha
      screen.enable = true;
      search.enable = true;
      term.enable = true;

      # always on, so the vault syncs even when kazuha and the phone are never
      # online together. it lives in the shared folder, so files.<domain> shows it
      syncthing = {
        enable = true;
        folders.main = "${config.dotnix.services.files.folder}/vaults/main";
      };
    };

    # on the data drive, so a dead root drive leaves them; a copy on another
    # machine is still to come
    backup.repository = "/srv/backup";
  };
}
