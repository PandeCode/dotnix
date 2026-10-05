# home.<domain>: the weather, this machine's load, an up/down light for every
# site, news and new releases of what it runs. status.<domain>:
# gatus checking each site end to end, name, certificate and all, and
# telling ntfy when one goes down
{ config, lib, ... }:

let
  inherit (config.dotnix) home;
  inherit (home) theme;

  cfg = config.dotnix.services.dashboard;

  glancePort = 8081;
  gatusPort = 8082;

  url = name: "https://${name}.${home.domain}";

  ntfy = config.dotnix.services.ntfy.enable;

  # where each service announces its releases
  repos = {
    atuin = "atuinsh/atuin";
    beszel = "henrygd/beszel";
    dav = "Kozea/Radicale";
    files = "gtsteffaniak/filebrowser";
    forgejo = "codeberg:forgejo/forgejo";
    money = "simonmichael/hledger";
    navidrome = "navidrome/navidrome";
    news = "miniflux/v2";
    ntfy = "binwiederhier/ntfy";
    read = "codeberg:readeck/readeck";
    syncthing = "syncthing/syncthing";
  };
in

{
  options.dotnix.services.dashboard = {
    enable = lib.options.mkEnableOption "a start page and status checks for dotnix.home.sites";

    weather = lib.options.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "Worcester, United States";
      description = "Place to show the weather for, or null for none.";
    };

    feeds = lib.options.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "RSS and Atom feeds to show.";
    };

    releases = lib.options.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "glanceapp/glance"
        "TwiN/gatus"
        "0xERR0R/blocky"
      ]
      ++ lib.attrsets.attrValues (
        lib.attrsets.filterAttrs (name: _: config.dotnix.services.${name}.enable) repos
      );
      defaultText = lib.literalMD "the start page, gatus, blocky and every enabled service";
      description = "Repositories to show new releases of, in glance's notation.";
    };
  };

  config = lib.modules.mkIf cfg.enable {
    services.glance = {
      enable = true;
      settings = {
        server.port = glancePort;
        # stylix sets the colors; the accent and the font come from here
        theme.primary-color = lib.modules.mkIf (theme != null) (
          lib.modules.mkForce (lib.strings.replaceStrings [ "%" ] [ "" ] theme.hsl.base0D)
        );
        document.head = lib.modules.mkIf (theme != null) ''
          <style>
            ${theme.import}
            html, body, input, button { font-family: var(--font); }
          </style>
        '';
        pages = [
          {
            name = config.networking.hostName;
            columns = [
              {
                size = "small";
                widgets =
                  lib.lists.optional (cfg.weather != null) {
                    type = "weather";
                    location = cfg.weather;
                  }
                  ++ [
                    {
                      type = "server-stats";
                      servers = [
                        {
                          type = "local";
                          name = config.networking.hostName;
                        }
                      ];
                    }
                  ];
              }
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
                    ) (lib.attrsets.filterAttrs (_: site: site.listed) home.sites);
                  }
                ]
                ++ lib.lists.optional (cfg.feeds != [ ]) {
                  type = "rss";
                  title = "News";
                  limit = 20;
                  collapse-after = 8;
                  feeds = map (url: { inherit url; }) cfg.feeds;
                };
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "releases";
                    # unauthenticated github allows 60 requests an hour
                    cache = "6h";
                    show-source-icon = true;
                    repositories = cfg.releases;
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
        ui = lib.attrsets.optionalAttrs (theme != null) {
          dark-mode = true;
          # its colors are "h s% l%" triplets
          custom-css = ''
            ${theme.import}
            /* above its own :root and :root.dark, in light mode too */
            html:root, html:root.dark {
            ${lib.strings.concatLines (
              lib.attrsets.mapAttrsToList (var: base: "  --${var}: ${theme.hsl.${base}};") {
                background = "base00";
                foreground = "base05";
                card = "base01";
                card-foreground = "base05";
                popover = "base01";
                popover-foreground = "base05";
                primary = "base0D";
                primary-foreground = "base00";
                secondary = "base02";
                secondary-foreground = "base05";
                muted = "base02";
                muted-foreground = "base04";
                accent = "base02";
                accent-foreground = "base07";
                destructive = "base08";
                destructive-foreground = "base00";
                border = "base02";
                input = "base02";
                ring = "base0D";
              }
            )}
            }
            html, body, input, button { font-family: var(--font); }
          '';
        };
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
