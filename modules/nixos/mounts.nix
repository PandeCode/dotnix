# network shares, mounted on first use, owned by the user and listed in the
# file manager's sidebar
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkOption;
  inherit (lib) types;
  inherit (config.dotnix) user;

  cfg = config.dotnix.mounts.smb;
in

{
  options.dotnix.mounts.smb = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          device = mkOption {
            type = types.str;
            example = "//server/share";
          };

          credentials = mkOption {
            type = types.str;
            description = "A file with `username=` and `password=` lines, read at mount time, so a secret's path.";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "More mount.cifs options.";
          };
        };
      }
    );
    default = { };
    description = "SMB shares by mount point.";
  };

  config = lib.modules.mkIf (cfg != { }) {
    fileSystems = lib.attrsets.mapAttrs (_: share: {
      inherit (share) device;
      fsType = "cifs";
      options = [
        "credentials=${share.credentials}"
        # yours, not root's, so you can write to it
        "uid=${user}"
        "gid=users"
        # mounted on first use and given up quickly, so a missing network
        # never hangs boot or a shell
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
      ]
      ++ share.options;
    }) cfg;

    environment.systemPackages = [ pkgs.cifs-utils ];

    home-manager.users.${user}.gtk.gtk3.bookmarks = lib.attrsets.mapAttrsToList (
      path: _: "file://${path} ${baseNameOf path}"
    ) cfg;
  };
}
