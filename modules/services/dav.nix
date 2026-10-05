# dav.<domain>: radicale, calendars and contacts over caldav and carddav,
# for the phone and any calendar app
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  inherit (config.dotnix) user;

  cfg = config.dotnix.services.dav;

  port = 5232;
  state = "/var/lib/radicale";
in

{
  options.dotnix.services.dav = {
    enable = mkEnableOption "radicale, at dav.<domain>";

    passwordFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Your password, read at run time, so a secret's path; the user is
        dotnix.user. There is no server without it.
      '';
    };
  };

  config = lib.modules.mkIf (cfg.enable && cfg.passwordFile != null) {
    services.radicale = {
      enable = true;
      settings = {
        server.hosts = [ "127.0.0.1:${toString port}" ];
        # made from the secret on every start, readable by radicale only
        auth = {
          type = "htpasswd";
          htpasswd_filename = "/run/radicale/users";
          htpasswd_encryption = "plain";
        };
        storage.filesystem_folder = "${state}/collections";
        # each user sees only their own calendars and contacts
        rights.type = "owner_only";
      };
    };

    systemd.services.radicale.serviceConfig = {
      RuntimeDirectory = "radicale";
      RuntimeDirectoryMode = "0700";
      LoadCredential = "password:${cfg.passwordFile}";
      ExecStartPre = pkgs.writeShellScript "dav-users" ''
        printf '%s:%s\n' ${user} "$(cat "$CREDENTIALS_DIRECTORY/password")" >/run/radicale/users
      '';
    };

    dotnix = {
      home.sites.dav = { inherit port; };
      backup.paths = [ state ];
    };
  };
}
