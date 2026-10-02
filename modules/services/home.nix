# <name>.home.arpa for every site, over tailscale only, with certificates
# from caddy's own CA
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

  cfg = config.dotnix.home;

  ca = "${self}/keys/home-ca.crt";
in

{
  options.dotnix.home = {
    enable = mkEnableOption "serving dotnix.home.sites to the tailnet";

    domain = mkOption {
      type = types.str;
      default = "home.arpa";
    };

    address = mkOption {
      type = types.str;
      example = "100.64.0.1";
      description = "This machine's tailscale address, from `tailscale ip -4`. Every name points here.";
    };

    sites = mkOption {
      type = types.attrsOf (
        types.submodule {
          options.port = mkOption { type = types.port; };
        }
      );
      default = { };
      description = "Each <name> is served at https://<name>.<domain> from this port on localhost.";
    };

    ca = mkOption {
      type = types.nullOr types.path;
      default = if builtins.pathExists ca then ca else null;
      defaultText = lib.literalExpression ''"''${self}/keys/home-ca.crt" when it exists'';
      description = "The root certificate of the server's CA, trusted by every machine.";
    };
  };

  config = mkMerge [
    (mkIf (cfg.ca != null) {
      security.pki.certificateFiles = [ cfg.ca ];
    })

    (mkIf cfg.enable {
      services.blocky = {
        enable = true;
        settings = {
          ports.dns = 53;
          upstreams.groups.default = [
            "1.1.1.1"
            "9.9.9.9"
          ];
          # subdomains included
          customDNS.mapping.${cfg.domain} = cfg.address;
        };
      };

      services.caddy = {
        enable = true;
        # the store is read-only; machines trust the CA through dotnix.home.ca
        globalConfig = "skip_install_trust";
        virtualHosts = lib.attrsets.mapAttrs' (
          name: site:
          lib.attrsets.nameValuePair "${name}.${cfg.domain}" {
            extraConfig = ''
              tls internal
              reverse_proxy 127.0.0.1:${toString site.port}
            '';
          }
        ) cfg.sites;
      };

      networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
        allowedTCPPorts = [
          53
          443
        ];
        allowedUDPPorts = [ 53 ];
      };
    })
  ];
}
