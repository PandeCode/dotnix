# stats.<domain>: the beszel hub. every machine runs an agent once
# keys/beszel.pub, the hub's public key, is in the repo; the hub connects to
# the agents over tailscale
{
  config,
  lib,
  self,
  ...
}:

let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;

  cfg = config.dotnix.services.beszel;

  key = "${self}/keys/beszel.pub";
  agentPort = 45876;
in

{
  options.dotnix.services.beszel = {
    enable = mkEnableOption "the beszel hub, at stats.<domain>";

    key = mkOption {
      type = types.nullOr types.str;
      default = if builtins.pathExists key then lib.strings.trim (builtins.readFile key) else null;
      defaultText = lib.literalExpression ''the contents of "''${self}/keys/beszel.pub" when it exists'';
      description = "The hub's public key. With it set, this machine runs an agent.";
    };
  };

  config = mkMerge [
    (mkIf (cfg.key != null) {
      services.beszel.agent = {
        enable = true;
        environment = {
          KEY = cfg.key;
          PORT = toString agentPort;
        };
      };

      networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
        agentPort
      ];
    })

    (mkIf cfg.enable {
      services.beszel.hub.enable = true;

      dotnix = {
        home.sites.stats.port = config.services.beszel.hub.port;
        backup.paths = [ "/var/lib/private/beszel-hub" ];
      };
    })
  ];
}
