# atuin.<domain>: shell history synced between machines, end-to-end
# encrypted, so the server only ever holds ciphertext
{ config, lib, ... }:

let
  cfg = config.dotnix.services.atuin;
in

{
  options.dotnix.services.atuin.enable =
    lib.options.mkEnableOption "the atuin sync server, at atuin.<domain>";

  config = lib.modules.mkIf cfg.enable {
    services.atuin = {
      enable = true;
      # reachable over tailscale only, so only your machines can sign up
      openRegistration = true;
    };

    services.postgresql.enable = true;

    dotnix = {
      home.sites.atuin.port = config.services.atuin.port;
      backup.databases = [ "atuin" ];
    };
  };
}
