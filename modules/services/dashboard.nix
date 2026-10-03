# home.<domain>: a link and an up/down light for every site. status.<domain>:
# gatus checking each site end to end, name, certificate and all, and
# telling ntfy when one goes down
{ config, lib, ... }:

let
  inherit (config.dotnix) home;

  cfg = config.dotnix.services.dashboard;

  glancePort = 8081;
  gatusPort = 8082;

  url = name: "https://${name}.${home.domain}";

  ntfy = config.dotnix.services.ntfy.enable;
in

{
  options.dotnix.services.dashboard.enable =
    lib.options.mkEnableOption "a start page and status checks for dotnix.home.sites";

  config = lib.modules.mkIf cfg.enable {
    services.glance = {
      enable = true;
      settings = {
        server.port = glancePort;
        pages = [
          {
            name = config.networking.hostName;
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "monitor";
                    title = "Sites";
                    cache = "1m";
                    sites = lib.attrsets.mapAttrsToList (
                      name: site:
                      {
                        title = name;
                        url = url name;
                      }
                      # straight to the service, so a broken proxy still shows
                      # which services are up
                      // lib.attrsets.optionalAttrs (site.port != null) {
                        check-url = "http://127.0.0.1:${toString site.port}";
                      }
                    ) home.sites;
                  }
                ];
              }
            ];
          }
        ];
      };
    };

    services.gatus = {
      enable = true;
      settings = {
        web = {
          address = "127.0.0.1";
          port = gatusPort;
        };
        storage = {
          type = "sqlite";
          path = "/var/lib/gatus/data.db";
        };
        alerting = lib.attrsets.optionalAttrs ntfy {
          ntfy = {
            url = "http://${config.services.ntfy-sh.settings.listen-http}";
            topic = config.networking.hostName;
            default-alert.send-on-resolved = true;
          };
        };
        endpoints = lib.attrsets.mapAttrsToList (name: _: {
          inherit name;
          url = url name;
          interval = "1m";
          # blocky directly: this machine may not use itself for dns
          client.dns-resolver = "udp://127.0.0.1:53";
          conditions = [
            "[STATUS] < 500"
            # caddy's internal CA issues 12h certificates and renews them
            # with about 4h left, so less than 1h means renewal is broken
            "[CERTIFICATE_EXPIRATION] > 1h"
          ];
          alerts = lib.lists.optional ntfy { type = "ntfy"; };
        }) home.sites;
      };
    };

    dotnix = {
      home.sites = {
        home.port = glancePort;
        status.port = gatusPort;
      };
      backup.paths = [ "/var/lib/private/gatus" ];
    };
  };
}
