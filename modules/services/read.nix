# read.<domain>: readeck, for saving articles to read later. it keeps the
# text and images, so they outlive the page
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

  cfg = config.dotnix.services.read;

  port = 8085;
  domain = "read.${home.domain}";

  # it only loads styles and fonts from itself, so caddy serves the theme
  # under its own name
  themePath = "/dotnix-theme";

  # its colors are "r g b" triplets in scales from 50 to 950, dark to light
  # in its dark mode
  rgb = list: lib.strings.concatMapStringsSep " " toString list;
  mix =
    a: b: t:
    lib.lists.zipListsWith (x: y: builtins.floor (x + (y - x) * t + 0.5)) a b;
  steps = [
    50
    100
    200
    300
    400
    500
    600
    700
    800
    900
    950
  ];
  scale =
    name: base:
    lib.lists.zipListsWith (step: color: "  --color-${name}-${toString step}: ${rgb color};") steps (
      map (t: mix theme.rgb.base00 theme.rgb.${base} t) [
        0.08
        0.15
        0.25
        0.45
        0.7
      ]
      ++ [ theme.rgb.${base} ]
      ++ map (t: mix theme.rgb.${base} theme.rgb.base07 t) [
        0.15
        0.3
        0.5
        0.7
        0.85
      ]
    );
  grays =
    let
      b = theme.rgb;
    in
    lib.lists.zipListsWith (step: color: "  --color-gray-${toString step}: ${rgb color};") steps [
      b.base00
      b.base01
      b.base02
      b.base03
      (mix b.base03 b.base04 0.5)
      b.base04
      (mix b.base04 b.base05 0.5)
      b.base05
      b.base06
      (mix b.base06 b.base07 0.5)
      b.base07
    ];

  templates = pkgs.writeTextDir "layout/head.html.tmpl" ''
    <link rel="stylesheet" href="${themePath}/theme.css" nonce="{{ cspnonce .ctx }}">
    <style nonce="{{ cspnonce .ctx }}">
      /* above its own light and dark palettes */
      html:root, html:root.dark {
      ${lib.strings.concatLines (
        grays
        ++ scale "blue" "base0D"
        ++ scale "red" "base08"
        ++ scale "green" "base0B"
        ++ scale "yellow" "base0A"
      )}
        --color-white: ${rgb theme.rgb.base07};
        --color-black: ${rgb theme.rgb.base00};
        --color-gray-light: ${rgb theme.rgb.base00};
        --color-gray-dark: ${rgb theme.rgb.base07};
        --color-app-bg: ${rgb theme.rgb.base00};
        --color-app-fg: ${rgb theme.rgb.base05};
        --color-primary: ${rgb theme.rgb.base0D};
        --color-primary-light: var(--color-blue-700);
        --color-primary-dark: var(--color-blue-300);
        --color-shadow: ${rgb theme.rgb.base00};
        --color-btn-default: ${rgb theme.rgb.base02};
        --color-btn-default-hover: ${rgb theme.rgb.base03};
        --color-btn-default-text: ${rgb theme.rgb.base05};
        --color-btn-primary: ${rgb theme.rgb.base0D};
        --color-btn-primary-hover: var(--color-blue-700);
        --color-btn-primary-text: ${rgb theme.rgb.base00};
        --color-btn-danger: ${rgb theme.rgb.base08};
        --color-btn-danger-hover: var(--color-red-700);
        --color-btn-danger-text: ${rgb theme.rgb.base00};
        color-scheme: dark;
      }
      /* everywhere it names its own sans, the reader's default included */
      html, body.body-base, .font-sans, .dialog, .dialog-image, .dialog-video,
      .annotator--content, .bookmark-display--font-public-sans {
        font-family: var(--font);
      }
    </style>
  '';

  start = pkgs.writeShellApplication {
    name = "read-start";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      # made once and kept, so logins survive restarts
      if [ ! -s secret-key ]; then
        (umask 077 && head -c 48 /dev/urandom | base64 -w0 >secret-key)
      fi
      READECK_SECRET_KEY=$(cat secret-key)
      export READECK_SECRET_KEY

      # makes the user, or sets its password again
      READECK_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/password")
      export READECK_PASSWORD
      ${lib.meta.getExe pkgs.readeck} user -config config.toml \
        -u ${user} -p env:READECK_PASSWORD -group admin
      unset READECK_PASSWORD

      exec ${lib.meta.getExe pkgs.readeck} serve -config config.toml
    '';
  };
in

{
  options.dotnix.services.read = {
    enable = mkEnableOption "readeck, at read.<domain>";

    passwordFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Your password, read at run time, so a secret's path; the user is
        dotnix.user. It is set again on every start. There is no reader
        without it.
      '';
    };
  };

  config = lib.modules.mkIf (cfg.enable && cfg.passwordFile != null) {
    services.readeck = {
      enable = true;
      settings = {
        server = {
          host = "127.0.0.1";
          inherit port;
          base_url = "https://${domain}";
          allowed_hosts = [ domain ];
        };
        customize.extra_templates = lib.modules.mkIf (theme != null) "${templates}";
      };
    };

    systemd.services.readeck.serviceConfig = {
      ExecStart = lib.modules.mkForce (lib.meta.getExe start);
      LoadCredential = "password:${cfg.passwordFile}";
    };

    dotnix = {
      home.sites.read = {
        inherit port;
        extraConfig = lib.strings.optionalString (theme != null) ''
          handle_path ${themePath}/* {
            root * ${theme.root}
            header /font.otf Content-Type font/otf
            file_server
          }
        '';
      };
      backup.paths = [ "/var/lib/private/readeck" ];
    };
  };
}
