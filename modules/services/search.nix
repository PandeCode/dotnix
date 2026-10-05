# search.<domain>: searxng, a web search that asks google, duckduckgo,
# brave and the rest for you, without ads or tracking
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix) home;
  inherit (home) theme;

  cfg = config.dotnix.services.search;

  port = 8089;
  domain = "search.${home.domain}";

  # it has no setting for its own css, so caddy hands out its stylesheet
  # with the theme on top
  css = "/static/themes/simple/sxng-ltr.min.css";

  colors = {
    base-font = "var(--text)";
    base-background = "var(--bg)";
    base-background-mobile = "var(--bg)";
    url-font = "var(--accent)";
    url-visited-font = "var(--base0E)";
    header-background = "var(--surface)";
    header-border = "var(--border)";
    footer-background = "var(--surface)";
    footer-border = "var(--border)";
    sidebar-border = "var(--border)";
    sidebar-font = "var(--bright)";
    sidebar-background = "var(--surface)";
    backtotop-font = "var(--text)";
    backtotop-border = "var(--border)";
    backtotop-background = "var(--surface)";
    btn-background = "var(--accent)";
    btn-font = "var(--bg)";
    show-btn-background = "var(--overlay)";
    show-btn-font = "var(--bright)";
    search-border = "var(--border)";
    search-background = "var(--surface)";
    search-font = "var(--bright)";
    search-background-hover = "var(--accent)";
    error = "var(--error)";
    error-background = "color-mix(in oklab, var(--error) 15%, var(--bg))";
    warning = "var(--warn)";
    warning-background = "color-mix(in oklab, var(--warn) 15%, var(--bg))";
    success = "var(--ok)";
    success-background = "color-mix(in oklab, var(--ok) 15%, var(--bg))";
    categories-item-selected-font = "var(--accent)";
    categories-item-border-selected = "var(--accent)";
    autocomplete-font = "var(--bright)";
    autocomplete-border = "var(--border)";
    autocomplete-background = "var(--surface)";
    autocomplete-background-hover = "var(--overlay)";
    answer-font = "var(--text)";
    answer-background = "var(--surface)";
    result-keyvalue-col-table = "var(--bg)";
    result-keyvalue-odd = "var(--bg)";
    result-keyvalue-even = "var(--surface)";
    result-background = "var(--surface)";
    result-border = "var(--border)";
    result-url-font = "var(--bright)";
    result-vim-selected = "var(--overlay)";
    result-vim-arrow = "var(--accent)";
    result-description-highlight-font = "var(--bright)";
    result-link-font = "var(--accent)";
    result-link-font-highlight = "var(--accent)";
    result-link-visited-font = "var(--base0E)";
    result-publishdate-font = "var(--muted)";
    result-engines-font = "var(--muted)";
    result-search-url-border = "var(--border)";
    result-search-url-font = "var(--bright)";
    result-detail-font = "var(--bright)";
    result-detail-label-font = "var(--muted)";
    result-detail-background = "var(--bg)";
    result-detail-hr = "var(--border)";
    result-detail-link = "var(--accent)";
    result-image-span-font = "var(--text)";
    result-image-span-font-selected = "var(--bg)";
    result-image-background = "var(--bg)";
    settings-tr-hover = "var(--overlay)";
    settings-engine-description-font = "var(--muted)";
    settings-table-group-background = "var(--surface)";
    toolkit-badge-font = "var(--bright)";
    toolkit-badge-background = "var(--overlay)";
    toolkit-kbd-font = "var(--bg)";
    toolkit-kbd-background = "var(--bright)";
    toolkit-dialog-border = "var(--border)";
    toolkit-dialog-background = "var(--surface)";
    toolkit-tabs-label-border = "var(--bg)";
    toolkit-tabs-section-border = "var(--border)";
    toolkit-select-background = "var(--overlay)";
    toolkit-select-border = "var(--border)";
    toolkit-select-background-hover = "var(--base03)";
    toolkit-input-text-font = "var(--bright)";
    toolkit-checkbox-onoff-off-background = "var(--overlay)";
    toolkit-checkbox-onoff-on-background = "var(--overlay)";
    toolkit-checkbox-onoff-on-mark-background = "var(--accent)";
    toolkit-checkbox-onoff-on-mark-color = "var(--bg)";
    toolkit-checkbox-onoff-off-mark-background = "var(--text)";
    toolkit-checkbox-onoff-off-mark-color = "var(--bg)";
    toolkit-checkbox-label-background = "var(--bg)";
    toolkit-checkbox-label-border = "var(--border)";
    toolkit-checkbox-input-border = "var(--accent)";
    toolkit-engine-tooltip-border = "var(--border)";
    toolkit-engine-tooltip-background = "var(--bg)";
    doc-code = "var(--text)";
    doc-code-background = "var(--overlay)";
    favicon-background-color = "var(--text)";
    favicon-border-color = "var(--muted)";
  };

  overrides = pkgs.writeText "overrides.css" ''
    /* above its own dark colors */
    html:root.theme-dark {
    ${lib.strings.concatLines (lib.attrsets.mapAttrsToList (n: v: "  --color-${n}: ${v};") colors)}
      --color-base-font-rgb: ${lib.strings.concatMapStringsSep ", " toString theme.rgb.base05};
    }
    html, input, button, select, textarea { font-family: var(--font); }
  '';

  themed = pkgs.runCommand "searxng-theme" { } ''
    mkdir $out
    {
      echo ${lib.strings.escapeShellArg theme.import}
      cat $(find ${config.services.searx.package} -path "*/searx${css}")
      cat ${overrides}
    } >$out/theme.css
  '';
in

{
  options.dotnix.services.search.enable = lib.options.mkEnableOption "searxng, at search.<domain>";

  config = lib.modules.mkIf cfg.enable {
    services.searx = {
      enable = true;
      settings = {
        use_default_settings = true;
        general.instance_name = "search";
        server = {
          bind_address = "127.0.0.1";
          inherit port;
          base_url = "https://${domain}/";
          secret_key = "$SEARX_SECRET_KEY";
          # it's only reachable over tailscale, so no bot protection
          limiter = false;
          # images come through firefly, so the sites never see you
          image_proxy = true;
        };
        search = {
          autocomplete = "duckduckgo";
          favicon_resolver = "duckduckgo";
        };
        ui = {
          theme_args.simple_style = "dark";
          query_in_title = true;
        };
      };
      # the icons it fetches for each result, kept across restarts
      faviconsSettings.favicons = {
        cfg_schema = 1;
        cache.db_url = "/var/cache/searx/faviconcache.db";
      };
    };

    # made once and kept, so it survives restarts
    systemd.services.searx-init = {
      serviceConfig.StateDirectory = "searx";
      script = lib.modules.mkBefore ''
        key=/var/lib/searx/secret-key
        if [ ! -s $key ]; then
          (umask 077 && head -c 48 /dev/urandom | base64 -w0 >$key)
        fi
        SEARX_SECRET_KEY=$(cat $key)
        export SEARX_SECRET_KEY
      '';
    };

    dotnix.home.sites.search = {
      inherit port;
      extraConfig = lib.strings.optionalString (theme != null) ''
        handle ${css} {
          root * ${themed}
          rewrite * /theme.css
          file_server
        }
      '';
    };
  };
}
