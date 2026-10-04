# builds for the other machines over ssh, as nixremote. a machine may log in
# with its ssh host key once that key is in keys/hosts/<name>.pub
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

  cfg = config.dotnix.services.builder;

  user = "nixremote";
  # resolves to the home server, like every name under the domain
  host = "builder.${config.dotnix.home.domain}";

  dir = "${self}/keys/hosts";
  hostKey = name: "${dir}/${name}.pub";
  others =
    if builtins.pathExists dir then
      map (name: "${dir}/${name}") (
        lib.attrsets.attrNames (
          lib.attrsets.filterAttrs (
            name: type: type == "regular" && name != "${config.networking.hostName}.pub"
          ) (builtins.readDir dir)
        )
      )
    else
      [ ];
in

{
  options.dotnix.services.builder = {
    enable = mkEnableOption "building for the other machines";

    use = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "firefly";
      description = ''
        The machine to send builds to with `--builders @/etc/nix/machines`
        (`just switch-remote`). Needs its host key in keys/hosts/<name>.pub.
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      users = {
        users.${user} = {
          isSystemUser = true;
          group = user;
          # nix-daemon --stdio runs in it
          useDefaultShell = true;
          openssh.authorizedKeys.keyFiles = others;
        };
        groups.${user} = { };
      };

      services.openssh.settings.AllowUsers = [ user ];
      nix.settings.trusted-users = [ user ];
    })

    (mkIf (cfg.use != null && builtins.pathExists (hostKey cfg.use)) {
      # written to /etc/nix/machines but not used by default: this machine is
      # usually the faster one
      nix = {
        buildMachines = [
          {
            hostName = host;
            sshUser = user;
            sshKey = "/etc/ssh/ssh_host_ed25519_key";
            protocol = "ssh-ng";
            system = config.nixpkgs.hostPlatform.system;
            maxJobs = 4;
            supportedFeatures = [
              "benchmark"
              "big-parallel"
              "kvm"
              "nixos-test"
            ];
          }
        ];
        settings.builders-use-substitutes = true;
      };

      programs.ssh.knownHosts.${cfg.use} = {
        hostNames = [ host ];
        publicKeyFile = hostKey cfg.use;
      };
    })
  ];
}
