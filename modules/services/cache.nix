# cache.<domain>: this machine's nix store as a signed binary cache, so the
# other machines download what it has built instead of building it again
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

  cfg = config.dotnix.services.cache;

  port = 5000;

  # the public half of the signing key, made with
  # `nix-store --generate-binary-cache-key cache.<domain>-1 secret public`
  key = "${self}/keys/nix-cache";
in

{
  options.dotnix.services.cache = {
    enable = mkEnableOption "a binary cache of this machine's store, at cache.<domain>";

    signKeyPath = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The secret half of the key in keys/nix-cache, read at run time, so a secret's path. Unsigned paths are refused by the other machines.";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.harmonia.cache = {
        enable = true;
        signKeyPaths = lib.lists.optional (cfg.signKeyPath != null) cfg.signKeyPath;
        settings.bind = "127.0.0.1:${toString port}";
      };

      dotnix.home.sites.cache = { inherit port; };
    })

    # every other machine that trusts the home CA uses it
    (mkIf (!cfg.enable && config.dotnix.home.ca != null && builtins.pathExists key) {
      dotnix.nix.caches = [
        {
          url = "https://cache.${config.dotnix.home.domain}";
          key = lib.strings.trim (builtins.readFile key);
        }
      ];

      # off the tailnet it can't be reached; give up on it quickly
      nix.settings.connect-timeout = 5;
    })
  ];
}
