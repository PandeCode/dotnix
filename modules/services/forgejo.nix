# git.<domain>: forgejo. clones go over https through caddy, or over ssh on
# port 2222, which leaves 22 to the machine's own sshd
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotnix.services.forgejo;
  inherit (config.dotnix.home) theme;

  # forgejo's dark theme with its steel greys swapped for the ramp and its
  # orange for the accent
  steel =
    lib.lists.zipListsWith (shade: ramp: "  --steel-${toString shade}: var(--ramp-${toString ramp});")
      (map (i: 900 - 50 * i) (lib.lists.range 0 16))
      [
        0
        1
        2
        3
        4
        5
        6
        7
        8
        9
        10
        11
        12
        13
        13
        14
        14
      ];

  shades = lib.lists.concatMap (
    i:
    let
      n = toString i;
      p = toString (i * 12);
    in
    [
      "  --color-primary-dark-${n}: color-mix(in oklab, var(--accent), var(--bright) ${p}%);"
      "  --color-primary-light-${n}: color-mix(in oklab, var(--accent), var(--bg) ${p}%);"
    ]
  ) (lib.lists.range 1 7);

  alphas = map (
    i:
    "  --color-primary-alpha-${toString i}: color-mix(in oklab, var(--accent) ${toString i}%, transparent);"
  ) (map (i: i * 10) (lib.lists.range 1 9));

  themeCss = pkgs.writeText "theme-dotnix.css" ''
    @import "./theme-forgejo-dark.css";
    ${theme.import}
    gitea-theme-meta-info {
      --theme-display-name: "dotnix";
      --theme-color-scheme: "dark";
    }
    :root {
    ${lib.strings.concatLines (steel ++ shades ++ alphas)}
      --color-primary: var(--accent);
      --color-primary-contrast: var(--bg);
      --color-red: var(--base08);
      --color-orange: var(--base09);
      --color-yellow: var(--base0A);
      --color-green: var(--base0B);
      --color-teal: var(--base0C);
      --color-blue: var(--base0D);
      --color-violet: var(--base0E);
      --color-purple: var(--base0E);
      --color-brown: var(--base0F);
      --color-red-light: var(--base08);
      --color-orange-light: var(--base09);
      --color-yellow-light: var(--base0A);
      --color-green-light: var(--base0B);
      --color-teal-light: var(--base0C);
      --color-blue-light: var(--base0D);
      --color-violet-light: var(--base0E);
      --color-purple-light: var(--base0E);
      --color-brown-light: var(--base0F);
      --fonts-proportional: var(--font);
      --fonts-monospace: var(--font);
    }
  '';

  port = 3000;
  sshPort = 2222;

  domain = "git.${config.dotnix.home.domain}";
in

{
  options.dotnix.services.forgejo.enable = lib.options.mkEnableOption "forgejo, at git.<domain>";

  config = lib.modules.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      # sqlite is copied mid-write by restic; the dump is a consistent copy
      dump = {
        enable = true;
        # uncompressed, so restic can deduplicate between nights
        type = "tar";
      };
      settings = {
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = port;
          START_SSH_SERVER = true;
          SSH_PORT = sshPort;
          SSH_LISTEN_PORT = sshPort;
        };
        # accounts are made with `forgejo admin user create`
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
        ui = lib.modules.mkIf (theme != null) {
          THEMES = "dotnix,forgejo-auto,forgejo-light,forgejo-dark";
          DEFAULT_THEME = "dotnix";
        };
      };
    };

    systemd.tmpfiles.settings.forgejo-theme = lib.modules.mkIf (theme != null) {
      "${config.services.forgejo.customDir}/public/assets/css/theme-dotnix.css"."L+".argument =
        toString themeCss;
    };

    # for `forgejo admin`
    environment.systemPackages = [ config.services.forgejo.package ];

    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
      sshPort
    ];

    dotnix = {
      home.sites.git = { inherit port; };
      backup.paths = [ config.services.forgejo.dump.backupDir ];
    };
  };
}
