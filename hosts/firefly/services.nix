# what firefly serves; its address and passwords are private
{ config, ... }:

{
  dotnix = {
    services = {
      beszel.enable = true;
      dashboard.enable = true;
      files.enable = true;
      forgejo.enable = true;
      navidrome.enable = true;
      ntfy.enable = true;
      search.enable = true;

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
