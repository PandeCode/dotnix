# syncthing as the user: a folder syncs with every other device in the list
# unless it names some, over tailscale unless lan is on. the gui is at
# sync.<domain>
{ config, lib, ... }:

let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  inherit (config.dotnix) user;

  cfg = config.dotnix.services.syncthing;

  # every machine can share one list, so this one drops itself
  others = lib.attrsets.filterAttrs (name: _: name != config.networking.hostName) cfg.devices;

  guiPort = 8384;

  folder = types.submodule {
    options = {
      path = mkOption { type = types.str; };

      devices = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = "The devices it syncs with; null for all of them.";
      };

      type = mkOption {
        type = types.enum [
          "sendreceive"
          "sendonly"
          "receiveonly"
        ];
        default = "sendreceive";
        description = "sendonly ignores changes from the others; receiveonly keeps what you delete or change here out of theirs.";
      };

      keepDeleted = mkEnableOption "keeping files here that the others delete, for a copy that only grows";
    };
  };
in

{
  options.dotnix.services.syncthing = {
    enable = mkEnableOption "syncthing as the user";

    devices = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Device ids by name, this machine's own included. A machine's id: `syncthing --device-id` on it.";
    };

    folders = mkOption {
      type = types.attrsOf (types.coercedTo types.str (path: { inherit path; }) folder);
      default = { };
      example = {
        notes = "/home/alice/notes";
        screenshots = {
          path = "/home/alice/Pictures/Screenshots";
          devices = [ "server" ];
          type = "sendonly";
        };
        # and on the server: type = "receiveonly"; keepDeleted = true;
      };
      description = "Folders to sync, by id: a path, or a path with options.";
    };

    lan = mkEnableOption "syncing over the local network too, not only tailscale";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.syncthing = {
        enable = true;
        inherit user;
        group = "users";
        dataDir = "/home/${user}";
        openDefaultPorts = cfg.lan;

        settings = {
          devices = lib.attrsets.mapAttrs (_: id: { inherit id; }) others;
          folders = lib.attrsets.mapAttrs (_: f: {
            inherit (f) path type;
            ignoreDelete = f.keepDeleted;
            devices = lib.lists.filter (name: others ? ${name}) (
              if f.devices == null then lib.attrsets.attrNames cfg.devices else f.devices
            );
            ignorePerms = false;
          }) cfg.folders;
        };
      };
    }

    (mkIf (!cfg.lan) {
      networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
        allowedTCPPorts = [ 22000 ];
        allowedUDPPorts = [
          21027
          22000
        ];
      };
    })

    (mkIf config.dotnix.home.enable {
      services.syncthing = {
        guiAddress = "127.0.0.1:${toString guiPort}";
        # reached through caddy at sync.<domain>, a name the host check refuses
        settings.gui = {
          insecureSkipHostcheck = true;
          # closest to the stylix colors of its built-in themes
          theme = lib.modules.mkIf (config.dotnix.home.theme != null) "black";
        };
      };
      dotnix.home.sites.sync.port = guiPort;
    })
  ]);
}
