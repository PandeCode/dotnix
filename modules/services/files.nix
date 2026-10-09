# files.<domain> and smb://files.<domain>/files: one folder, in the browser
# and as a network drive, over tailscale only
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  inherit (config.dotnix) user;

  cfg = config.dotnix.services.files;

  port = 8083;
  state = "/var/lib/filebrowser-quantum";
  inherit (config.dotnix.home) theme;

  settings = (pkgs.formats.yaml { }).generate "filebrowser.yaml" {
    server = {
      inherit port;
      listen = "127.0.0.1";
      database = "${state}/database.db";
      cacheDir = "/var/cache/filebrowser-quantum";
      externalUrl = "https://files.${config.dotnix.home.domain}";
      disableUpdateCheck = true;
      sources = [
        {
          path = cfg.folder;
          name = "files";
          config.defaultEnabled = true;
        }
      ];
      # group-readable, so services in the users group (navidrome) can read
      # what is uploaded
      filesystem = {
        createFilePermission = "640";
        createDirectoryPermission = "750";
      };
    };
    auth.adminUsername = user;
    frontend = {
      name = "files";
      styling = lib.attrsets.optionalAttrs (theme != null) {
        darkBackground = theme.colors.base00;
        customCSS = toString (
          pkgs.writeText "files.css" ''
            ${theme.import}
            .dark-mode {
              --alt-background: var(--overlay);
              --surfacePrimary: var(--surface);
              --surfaceSecondary: var(--overlay);
              --divider: var(--border);
              --textPrimary: var(--text);
              --textSecondary: var(--muted);
              --iconBackground: var(--surface);
              --activeWhiteIcon: var(--bright);
            }
            :root {
              --primaryColor: var(--accent);
              --blue: var(--base0D);
              --dark-blue: var(--accent-hover);
              --red: var(--base08);
              --dark-red: var(--base08);
              --icon-red: var(--base08);
              --icon-orange: var(--base09);
              --icon-yellow: var(--base0A);
              --icon-green: var(--base0B);
              --icon-blue: var(--base0D);
              --icon-violet: var(--base0E);
            }
            body, input, button, textarea, select {
              font-family: var(--font);
            }
          ''
        );
      };
    };
  };
in

{
  options.dotnix.services.files = {
    enable = mkEnableOption "a shared folder, at files.<domain> and over smb";

    folder = mkOption {
      type = types.str;
      default = "/srv/files";
    };

    passwordFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The password of dotnix.user for smb and the browser, read at run time,
        so a secret's path.
        Without it there is no browser, and smb needs one set by hand with
        `sudo smbpasswd -a <user>`.
      '';
    };

    views = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        docs = "/var/lib/paperless/media/documents/archive";
      };
      description = "Folders of other services, shown read-only and as yours at apps/<name>.";
    };
  };

  config = mkIf cfg.enable {
    # the maintained fork of file browser, which was archived in 2026. the
    # smb password is the browser's too, so no password, no browser
    systemd.services.filebrowser-quantum = mkIf (cfg.passwordFile != null) {
      description = "FileBrowser Quantum";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment.FILEBROWSER_CONFIG = settings;
      # set again on every start, so changing the secret changes the login
      script = ''
        FILEBROWSER_ADMIN_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/password")
        export FILEBROWSER_ADMIN_PASSWORD
        exec ${lib.meta.getExe pkgs.filebrowser-quantum}
      '';
      serviceConfig = {
        # as the user, so files from the browser, smb and syncthing have one owner
        User = user;
        Group = "users";
        UMask = "0027";
        StateDirectory = "filebrowser-quantum";
        CacheDirectory = "filebrowser-quantum";
        WorkingDirectory = state;
        LoadCredential = "password:${cfg.passwordFile}";
        Restart = "on-failure";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.folder ];
      };
    };

    systemd.tmpfiles.settings.files.${cfg.folder}.d = {
      inherit user;
      group = "users";
      mode = "0750";
    };

    services.samba = {
      enable = true;
      # names come from blocky, not netbios broadcasts
      nmbd.enable = false;
      winbindd.enable = false;
      settings = {
        global = {
          "server min protocol" = "SMB3";
          "map to guest" = "never";
          # behind the firewall too, in case a port is ever opened wider
          "hosts allow" = "100.64.0.0/10 fd7a:115c:a1e0::/48 127.0.0.1 ::1";
        };
        files = {
          path = cfg.folder;
          "valid users" = user;
          "read only" = "no";
        };
      };
    };

    systemd.services.samba-password = mkIf (cfg.passwordFile != null) {
      description = "Set the smb password of ${user}";
      wantedBy = [ "multi-user.target" ];
      before = [ "samba-smbd.service" ];
      path = [ config.services.samba.package ];
      script = ''
        password=$(cat ${lib.strings.escapeShellArg cfg.passwordFile})
        printf '%s\n%s\n' "$password" "$password" | smbpasswd -s -a ${user}
      '';
      serviceConfig.Type = "oneshot";
    };

    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [ 445 ];

    # bindfs shows the files as yours without touching the originals, and
    # mounts on first use, once the service has made the folder
    fileSystems = lib.attrsets.mapAttrs' (
      name: source:
      lib.attrsets.nameValuePair "${cfg.folder}/apps/${name}" {
        device = source;
        fsType = "fuse.bindfs";
        options = [
          "ro"
          "allow_other"
          "force-user=${user}"
          "force-group=users"
          "perms=0640:ug+X"
          "x-systemd.automount"
          "nofail"
        ];
      }
    ) cfg.views;
    system.fsPackages = lib.lists.optional (cfg.views != { }) pkgs.bindfs;

    dotnix = {
      home.sites.files = mkIf (cfg.passwordFile != null) { inherit port; };
      # against deleting by mistake; a copy off this drive is still to come
      backup.paths = [
        cfg.folder
        state
      ];
      # each service backs up its own folder
      backup.exclude = lib.lists.optional (cfg.views != { }) "${cfg.folder}/apps";
    };
  };
}
