# syncthing as the user: every folder syncs with every other device in the
# list, over tailscale unless lan is on. the gui is at sync.<domain>
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
      type = types.attrsOf types.str;
      default = { };
      example = {
        notes = "/home/alice/notes";
      };
      description = "Folders to sync, by id.";
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
          folders = lib.attrsets.mapAttrs (_: path: {
            inherit path;
            devices = lib.attrsets.attrNames others;
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
