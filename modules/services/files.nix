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
    frontend.name = "files";
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

    dotnix = {
      home.sites.files = mkIf (cfg.passwordFile != null) { inherit port; };
      # against deleting by mistake; a copy off this drive is still to come
      backup.paths = [
        cfg.folder
        state
      ];
    };
  };
}
