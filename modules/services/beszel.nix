# stats.<domain>: the beszel hub. every machine runs an agent once
# keys/beszel/hub.pub, the hub's public key, is in the repo; the hub connects to
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

  key = "${self}/keys/beszel/hub.pub";
  agentPort = 45876;

  # the agent only takes globs of services to show, so hiding some means
  # every name that doesn't start with one of them: [!l]*, l[!l]*, ...
  # it puts .service after each, so the bare l, ll, ... need their own.
  # a - goes first, where it can't make a range
  showing =
    prefixes: start:
    let
      firsts = lib.lists.unique (map (lib.strings.substring 0 1) prefixes);
      sorted = lib.lists.sort (a: b: a == "-" || (b != "-" && a < b)) firsts;
      rest = c: map (lib.strings.substring 1 (-1)) (lib.lists.filter (lib.strings.hasPrefix c) prefixes);
    in
    lib.lists.optionals (!lib.lists.elem "" prefixes) (
      lib.lists.optional (start != "") start
      ++ [ "${start}[!${lib.strings.concatStrings sorted}]*" ]
      ++ lib.lists.concatMap (c: showing (rest c) "${start}${c}") sorted
    );
in

{
  options.dotnix.services.beszel = {
    enable = mkEnableOption "the beszel hub, at stats.<domain>";

    key = mkOption {
      type = types.nullOr types.str;
      default = if builtins.pathExists key then lib.strings.trim (builtins.readFile key) else null;
      defaultText = lib.literalExpression ''the contents of "''${self}/keys/beszel/hub.pub" when it exists'';
      description = "The hub's public key. With it set, this machine runs an agent.";
    };

    hiddenServices = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "getty" ];
      description = "Beginnings of systemd service names to leave out of this machine's services on the stats page.";
    };
  };

  config = mkMerge [
    (mkIf (cfg.key != null) {
      services.beszel.agent = {
        enable = true;
        environment = {
          KEY = cfg.key;
          PORT = toString agentPort;
        }
        // lib.attrsets.optionalAttrs (cfg.hiddenServices != [ ]) {
          SERVICE_PATTERNS = lib.strings.concatStringsSep "," (showing cfg.hiddenServices "");
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
