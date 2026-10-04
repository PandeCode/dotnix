# files.<domain> and smb://files.<domain>/files: one folder, in the browser
# and as a network drive, over tailscale only
{ config, lib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  inherit (config.dotnix) user;

  cfg = config.dotnix.services.files;

  port = 8083;
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
        The smb password of dotnix.user, read at run time, so a secret's path.
        Without it, set one by hand with `sudo smbpasswd -a <user>`.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.filebrowser = {
      enable = true;
      # as the user, so files from the browser, smb and syncthing have one owner
      inherit user;
      group = "users";
      settings = {
        inherit port;
        address = "127.0.0.1";
        root = cfg.folder;
      };
    };

    # nixpkgs keeps the folder and uploads to the user alone; group-readable
    # instead, so services in the users group (navidrome) can read them
    systemd.tmpfiles.settings.filebrowser.${cfg.folder}.d.mode = lib.modules.mkForce "0750";
    systemd.services.filebrowser.serviceConfig.UMask = lib.modules.mkForce "0027";

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
      home.sites.files = { inherit port; };
      # against deleting by mistake; a copy off this drive is still to come
      backup.paths = [
        cfg.folder
        "/var/lib/filebrowser"
      ];
    };
  };
}
