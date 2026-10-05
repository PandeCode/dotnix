# photos.<domain>: immich, your phone's photos backed up and searchable, by
# what's in them and who. the iphone app uploads in the background
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
  inherit (config.dotnix.home) domain theme;

  cfg = config.dotnix.services.photos;
  immich = config.services.immich;

  url = "https://photos.${domain}";
  # it logs in by email; this one only has to look like one
  email = "${user}@${domain}";
  nvidia = config.dotnix.hardware.nvidia.enable;

  # its dark mode, which the theme fills in: scales run from 50, darkest,
  # to 950, lightest
  steps = [
    "50"
    "100"
    "200"
    "300"
    "400"
    "500"
    "600"
    "700"
    "800"
    "900"
    "950"
  ];
  mixes = [
    "var(--base00) 85%"
    "var(--base00) 70%"
    "var(--base00) 50%"
    "var(--base00) 30%"
    "var(--base00) 15%"
    null
    "var(--base07) 15%"
    "var(--base07) 30%"
    "var(--base07) 50%"
    "var(--base07) 70%"
    "var(--base07) 85%"
  ];
  scale =
    name: base:
    lib.lists.zipListsWith (
      step: mix:
      "  --immich-ui-${name}-${step}: ${
          if mix == null then "var(--${base})" else "color-mix(in oklab, var(--${base}), ${mix})"
        };"
    ) steps mixes;
  # tailwind's light to dark
  neutrals = lib.lists.zipListsWith (step: base: "  --color-neutral-${step}: var(--${base});") steps [
    "base07"
    "base06"
    "base05"
    "base04"
    "base04"
    "base03"
    "base03"
    "base02"
    "base01"
    "base01"
    "base00"
  ];
  rgb = base: lib.strings.concatMapStringsSep " " toString theme.rgb.${base};

  css = ''
    ${theme.import}
    :root.dark {
    ${lib.strings.concatLines (
      neutrals
      ++ scale "primary" "base0D"
      ++ scale "danger" "base08"
      ++ scale "success" "base0B"
      ++ scale "warning" "base0A"
      ++ scale "info" "base0C"
    )}
      --immich-ui-light: var(--base00);
      --immich-ui-dark: var(--base05);
      --immich-ui-muted: var(--base04);
      --immich-ui-gray: var(--base01);
      --immich-dark-primary: ${rgb "base0D"};
      --immich-dark-bg: ${rgb "base00"};
      --immich-dark-fg: ${rgb "base05"};
      --immich-dark-gray: ${rgb "base01"};
      --font-sans: var(--font);
    }
    :root {
      font-family: var(--font);
    }
  '';

  # immich has no config for its users, only its api: the first one is the
  # admin
  seed = pkgs.writeShellApplication {
    name = "photos-seed";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.coreutils
    ];
    text = ''
      api=http://127.0.0.1:${toString immich.port}/api
      for _ in $(seq 120); do
        curl -sf "$api/server/ping" >/dev/null && break
        sleep 1
      done

      password=$(cat "$CREDENTIALS_DIRECTORY/password")
      if [ "$(curl -sf "$api/server/config" | jq .isInitialized)" = false ]; then
        jq -n --arg p "$password" '{email: "${email}", name: "${user}", password: $p}' |
          curl -sf -H 'Content-Type: application/json' -d @- "$api/auth/admin-sign-up" >/dev/null
        token=$(jq -n --arg p "$password" '{email: "${email}", password: $p}' |
          curl -sf -H 'Content-Type: application/json' -d @- "$api/auth/login" | jq -r .accessToken)
        id=$(curl -sf -H "Authorization: Bearer $token" "$api/users/me" | jq -r .id)
        # library/<you>/ on disk, instead of library/admin/
        curl -sf -X PUT -H "Authorization: Bearer $token" -H 'Content-Type: application/json' \
          -d '{"storageLabel": "${user}"}' "$api/admin/users/$id" >/dev/null
      fi
    '';
  };
in

{
  options.dotnix.services.photos = {
    enable = mkEnableOption "immich, at photos.<domain>";

    folder = mkOption {
      type = types.str;
      default = "/srv/photos";
      description = "Where the photos and everything made from them live, best on a big drive.";
    };

    passwordFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Your password, read at run time, so a secret's path; you log in as
        dotnix.user@<domain>. It is set once, when the user is made. There
        are no photos without it.
      '';
    };
  };

  config = lib.modules.mkIf (cfg.enable && cfg.passwordFile != null) {
    services.immich = {
      enable = true;
      # its default, localhost, can end up on ipv6 only, where caddy and the
      # seed don't look
      host = "127.0.0.1";
      mediaLocation = cfg.folder;
      # to reach the gpu for video
      accelerationDevices = lib.modules.mkIf nvidia null;
      # the admin page shows these read-only; change them here
      settings = {
        server.externalDomain = url;
        # photos land in library/<you>/<year>/<date>/
        storageTemplate = {
          enabled = true;
          template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
        };
        # iphone videos are converted for the browser on the gpu; it falls
        # back to the cpu if that fails
        ffmpeg.accel = lib.modules.mkIf nvidia "nvenc";
        theme.customCss = lib.strings.optionalString (theme != null) css;
      };
    };

    systemd.services.photos-seed = {
      description = "Make Immich's first user";
      wantedBy = [ "immich-server.service" ];
      after = [ "immich-server.service" ];
      partOf = [ "immich-server.service" ];
      serviceConfig = {
        Type = "oneshot";
        LoadCredential = "password:${cfg.passwordFile}";
        ExecStart = lib.meta.getExe seed;
      };
    };

    # the big drive mounts with nofail; immich waits for it or doesn't start
    systemd.services.immich-server.unitConfig.RequiresMountsFor = [ cfg.folder ];

    # immich only makes its own folder when it's the default one
    systemd.tmpfiles.settings.immich.${cfg.folder}.d = {
      inherit (immich) user group;
      mode = "0700";
    };

    dotnix = {
      home.sites.photos.port = immich.port;
      # read-only at files.<domain>, like the other apps
      services.files.views.photos = "${cfg.folder}/library/${user}";
      backup = {
        # thumbnails and converted videos are made again from these
        paths = map (dir: "${cfg.folder}/${dir}") [
          "library"
          "upload"
          "profile"
        ];
        databases = [ immich.database.name ];
      };
    };
  };
}
