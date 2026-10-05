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

  protect = lib.lists.any (site: site.protect) (lib.attrsets.attrValues cfg.sites);
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
          options = {
            port = mkOption {
              type = types.nullOr types.port;
              default = null;
              description = "A service on localhost to pass requests to.";
            };

            root = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "A folder of files to serve instead.";
            };

            extraConfig = mkOption {
              type = types.lines;
              default = "";
              description = "More caddy directives for the site.";
            };

            listed = mkOption {
              type = types.bool;
              default = true;
              description = "Shown on the start page. It is checked either way.";
            };

            protect = mkEnableOption "asking for dotnix.user and dotnix.home.passwordFile first, for apps with no login of their own";
          };
        }
      );
      default = { };
      description = "Each <name> is served at https://<name>.<domain>, from a port on localhost or a folder.";
    };

    adblock = {
      enable =
        mkEnableOption "blocking ads and trackers for every machine that asks this server for DNS"
        // {
          default = true;
        };

      lists = mkOption {
        type = types.listOf types.str;
        default = [ "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.txt" ];
        description = "Blocklists to download, refreshed daily.";
      };

      allow = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "*.example.com" ];
        description = "Domains to let through even when a list blocks them.";
      };
    };

    passwordFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The password for protected sites, read at run time, so a secret's path.";
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
      assertions =
        lib.attrsets.mapAttrsToList (name: site: {
          assertion = (site.port == null) != (site.root == null);
          message = "dotnix.home.sites.${name} needs exactly one of port and root.";
        }) cfg.sites
        ++ [
          {
            assertion = protect -> cfg.passwordFile != null;
            message = "dotnix.home.passwordFile is needed for protected sites.";
          }
        ];

      services.blocky = {
        enable = true;
        settings = {
          ports.dns = 53;
          upstreams.groups.default = [
            "1.1.1.1"
            "9.9.9.9"
          ];
          # list downloads and upstreams resolve without going through blocky itself
          bootstrapDns = [ "1.1.1.1" ];
          # subdomains included
          customDNS.mapping.${cfg.domain} = cfg.address;
          # for the blocky cli: `blocky blocking disable --duration 5m`
          ports.http = "127.0.0.1:4000";
          caching.prefetching = true;
          blocking = mkIf cfg.adblock.enable {
            denylists.ads = cfg.adblock.lists;
            allowlists.ads = mkIf (cfg.adblock.allow != [ ]) [ (lib.strings.concatLines cfg.adblock.allow) ];
            clientGroupsBlock.default = [ "ads" ];
            # answer straight away and block once the lists are in, so names never stop resolving
            loading.strategy = "fast";
          };
        };
      };

      environment.systemPackages = [ config.services.blocky.package ];

      services.caddy = {
        enable = true;
        # the store is read-only; machines trust the CA through dotnix.home.ca
        globalConfig = "skip_install_trust";
        virtualHosts = lib.attrsets.mapAttrs' (
          name: site:
          lib.attrsets.nameValuePair "${name}.${cfg.domain}" {
            extraConfig = ''
              tls internal
              ${lib.strings.optionalString site.protect ''
                basic_auth {
                  ${config.dotnix.user} {$HOME_PASSWORD_HASH}
                }
              ''}
              ${site.extraConfig}
            ''
            + (
              if site.port != null then
                "reverse_proxy 127.0.0.1:${toString site.port}"
              else
                ''
                  root * ${site.root}
                  file_server
                ''
            );
          }
        ) cfg.sites;
      };

      # caddy only checks a hash, made from the secret before it starts
      services.caddy.environmentFile = mkIf protect "/run/caddy-password/env";
      systemd.services.caddy-password = mkIf protect {
        description = "Hash dotnix.home.passwordFile for caddy";
        requiredBy = [ "caddy.service" ];
        before = [ "caddy.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          RuntimeDirectory = "caddy-password";
          RuntimeDirectoryMode = "0700";
          LoadCredential = "password:${cfg.passwordFile}";
        };
        script = ''
          hash=$(${lib.meta.getExe config.services.caddy.package} hash-password <"$CREDENTIALS_DIRECTORY/password")
          echo "HOME_PASSWORD_HASH='$hash'" >/run/caddy-password/env
        '';
      };

      # caddy's CA: losing its key means trusting a new one everywhere
      dotnix.backup.paths = [ "/var/lib/caddy" ];

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
