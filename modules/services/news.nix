# news.<domain>: miniflux, a feed reader that remembers what you have read
# on every machine. it starts with the feeds given here, one category per
# first tag
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  inherit (config.dotnix) home user;
  inherit (home) theme;

  cfg = config.dotnix.services.news;

  port = 8084;
  api = "http://127.0.0.1:${toString port}/v1";

  categories = lib.lists.groupBy (
    feed: if feed.tags == [ ] then "all" else lib.lists.head feed.tags
  ) cfg.feeds;

  opml = pkgs.writeText "feeds.opml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <opml version="2.0">
      <head><title>feeds</title></head>
      <body>
    ${lib.strings.concatStrings (
      lib.attrsets.mapAttrsToList (name: feeds: ''
        <outline text="${lib.strings.escapeXML name}">
        ${lib.strings.concatMapStrings (feed: ''
          <outline type="rss" text="${lib.strings.escapeXML feed.url}" xmlUrl="${lib.strings.escapeXML feed.url}"/>
        '') feeds}
        </outline>
      '') categories
    )}
      </body>
    </opml>
  '';

  # its own themes are dark or light; the colors and the font come from
  # theme.<domain>, which it has to be told it may load from
  settings = pkgs.writeText "news.json" (
    builtins.toJSON (
      lib.attrsets.optionalAttrs (theme != null) {
        theme = "dark_sans_serif";
        external_font_hosts = "theme.${home.domain}";
        stylesheet = ''
          ${theme.import}
          :root {
            --font-family: var(--font);
            --body-color: var(--text);
            --body-background: var(--bg);
            --hr-border-color: var(--border);
            --title-color: var(--text);
            --link-color: var(--accent);
            --link-focus-color: var(--accent-hover);
            --link-hover-color: var(--accent-hover);
            --link-visited-color: var(--base0E);
            --header-list-border-color: var(--border);
            --header-link-color: var(--text);
            --header-link-focus-color: var(--accent);
            --header-link-hover-color: var(--accent);
            --header-active-link-color: var(--bright);
            --page-header-title-color: var(--bright);
            --page-header-title-border-color: var(--border);
            --logo-color: var(--bright);
            --logo-hover-color-span: var(--accent);
            --table-border-color: var(--border);
            --table-th-background: var(--surface);
            --table-th-color: var(--text);
            --table-tr-hover-background-color: var(--surface);
            --table-tr-hover-color: var(--bright);
            --button-primary-border-color: var(--accent);
            --button-primary-background: var(--accent);
            --button-primary-color: var(--bg);
            --button-primary-focus-border-color: var(--accent-hover);
            --button-primary-focus-background: var(--accent-hover);
            --input-border: 1px solid var(--border);
            --input-background: var(--surface);
            --input-color: var(--text);
            --input-placeholder-color: var(--muted);
            --input-focus-color: var(--bright);
            --input-focus-border-color: var(--accent);
            --input-focus-box-shadow: 0 0 6px var(--accent-soft);
            --alert-color: var(--text);
            --alert-background-color: var(--surface);
            --alert-border-color: var(--border);
            --alert-success-color: var(--ok);
            --alert-success-background-color: var(--surface);
            --alert-success-border-color: var(--ok);
            --alert-error-color: var(--error);
            --alert-error-background-color: var(--surface);
            --alert-error-border-color: var(--error);
            --alert-info-color: var(--info);
            --alert-info-background-color: var(--surface);
            --alert-info-border-color: var(--info);
            --panel-background: var(--surface);
            --panel-border-color: var(--border);
            --panel-color: var(--text);
            --pagination-link-color: var(--accent);
            --pagination-border-color: var(--border);
            --category-color: var(--text);
            --category-background-color: var(--surface);
            --category-border-color: var(--border);
            --category-link-color: var(--muted);
            --category-link-hover-color: var(--accent);
            --item-border-color: var(--border);
            --item-status-read-title-link-color: var(--muted);
            --item-status-read-title-focus-color: var(--accent);
            --item-meta-focus-color: var(--text);
            --item-meta-li-color: var(--muted);
            --current-item-border-color: var(--accent);
            --current-item-box-shadow: 0 0 6px var(--accent-soft);
            --entry-header-border-color: var(--border);
            --entry-header-title-link-color: var(--bright);
            --entry-content-color: var(--text);
            --entry-content-code-color: var(--bright);
            --entry-content-code-background: var(--surface);
            --entry-content-code-border-color: var(--border);
            --entry-content-quote-color: var(--muted);
            --entry-content-abbr-border-color: var(--muted);
            --entry-content-aside-border-color: var(--muted);
            --entry-enclosure-border-color: var(--border);
            --parsing-error-color: var(--text);
            --feed-parsing-error-background-color: color-mix(in oklab, var(--error) 15%, var(--bg));
            --feed-parsing-error-border-color: var(--error);
            --feed-has-unread-background-color: var(--surface);
            --feed-has-unread-border-color: var(--accent);
            --category-has-unread-background-color: var(--surface);
            --category-has-unread-border-color: var(--accent);
            --keyboard-shortcuts-li-color: var(--text);
            --counter-color: var(--muted);
          }
        '';
      }
    )
  );

  # the feeds and settings go in once per change, so whatever you change in
  # the app stays until they do
  seed = pkgs.writeShellApplication {
    name = "news-seed";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      jq
    ];
    text = ''
      stamp="$STATE_DIRECTORY/seeded"
      want="${opml} ${settings}"
      [ "$(cat "$stamp" 2>/dev/null)" = "$want" ] && exit 0

      auth=$(printf '%s:%s' ${user} "$(cat "$CREDENTIALS_DIRECTORY/password")" | base64 -w0)
      call() {
        curl --fail-with-body --silent --show-error \
          --header @<(printf 'Authorization: Basic %s' "$auth") "$@"
      }

      id=$(call ${api}/me | jq .id)
      # feeds already there are skipped
      call --data-binary @${opml} ${api}/import
      echo
      if [ "$(jq length ${settings})" != 0 ]; then
        call --request PUT --data-binary @${settings} "${api}/users/$id" >/dev/null
      fi

      echo "$want" >"$stamp"
    '';
  };
in

{
  options.dotnix.services.news = {
    enable = mkEnableOption "miniflux, at news.<domain>";

    feeds = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            url = mkOption { type = types.str; };
            tags = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "The first one is its category.";
            };
          };
        }
      );
      default = [ ];
      description = "Feeds to subscribe to. Taking one out here leaves it subscribed.";
    };

    passwordFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Your password, read at run time, so a secret's path; the user is
        dotnix.user. Only read when the user is made, on first start. There is
        no reader without it.
      '';
    };
  };

  config = lib.modules.mkIf (cfg.enable && cfg.passwordFile != null) {
    services.miniflux = {
      enable = true;
      # the user's name; the password comes in as a credential
      adminCredentialsFile = pkgs.writeText "news-admin" "ADMIN_USERNAME=${user}\n";
      config = {
        LISTEN_ADDR = "127.0.0.1:${toString port}";
        BASE_URL = "https://news.${home.domain}/";
        ADMIN_PASSWORD_FILE = "/run/credentials/miniflux.service/password";
      };
    };

    systemd.services = {
      miniflux.serviceConfig.LoadCredential = "password:${cfg.passwordFile}";

      news-seed = {
        description = "Subscribe miniflux to dotnix.services.news.feeds";
        wantedBy = [ "multi-user.target" ];
        requires = [ "miniflux.service" ];
        after = [ "miniflux.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.meta.getExe seed;
          DynamicUser = true;
          StateDirectory = "news-seed";
          LoadCredential = "password:${cfg.passwordFile}";
        };
      };
    };

    dotnix = {
      home.sites.news = { inherit port; };
      backup.databases = [ "miniflux" ];
    };
  };
}
