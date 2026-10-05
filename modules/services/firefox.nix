# firefox.<domain>: mozilla's sync server, so librewolf's bookmarks, history,
# tabs and settings sync through firefly. you still sign in with a mozilla
# account, which only vouches for you: the data is encrypted by the browser
# and kept here
{
  config,
  lib,
  pkgs,
  ...
}:

let
  port = 8088;
  secrets = "/var/lib/firefox-sync/env";
in

{
  options.dotnix.services.firefox.enable =
    lib.options.mkEnableOption "the firefox sync server, at firefox.<domain>";

  config = lib.modules.mkIf config.dotnix.services.firefox.enable {
    services.firefox-syncserver = {
      enable = true;
      database = {
        type = "postgresql";
        createLocally = true;
      };
      inherit secrets;
      singleNode = {
        enable = true;
        hostname = "firefox.${config.dotnix.home.domain}";
        enableTLS = true;
        # you, on every device
        capacity = 1;
      };
      settings = {
        inherit port;
        host = "127.0.0.1";
      };
    };

    # signs the tokens it hands out; made once and kept
    systemd.services.firefox-sync-secret = {
      description = "Make the firefox sync server's secret";
      requiredBy = [ "firefox-syncserver.service" ];
      before = [ "firefox-syncserver.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "firefox-sync";
        StateDirectoryMode = "0700";
        UMask = "0077";
      };
      script = ''
        [ -s ${secrets} ] || echo "SYNC_MASTER_SECRET=$(${pkgs.openssl}/bin/openssl rand -hex 32)" >${secrets}
      '';
    };

    dotnix = {
      # an api for browsers, nothing to open
      home.sites.firefox = {
        inherit port;
        listed = false;
      };
      backup = {
        paths = [ "/var/lib/firefox-sync" ];
        databases = [ config.services.firefox-syncserver.database.name ];
      };
    };
  };
}
