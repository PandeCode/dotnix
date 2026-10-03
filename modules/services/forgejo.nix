# git.<domain>: forgejo. clones go over https through caddy, or over ssh on
# port 2222, which leaves 22 to the machine's own sshd
{ config, lib, ... }:

let
  cfg = config.dotnix.services.forgejo;

  port = 3000;
  sshPort = 2222;

  domain = "git.${config.dotnix.home.domain}";
in

{
  options.dotnix.services.forgejo.enable = lib.options.mkEnableOption "forgejo, at git.<domain>";

  config = lib.modules.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      # sqlite is copied mid-write by restic; the dump is a consistent copy
      dump = {
        enable = true;
        # uncompressed, so restic can deduplicate between nights
        type = "tar";
      };
      settings = {
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = port;
          START_SSH_SERVER = true;
          SSH_PORT = sshPort;
          SSH_LISTEN_PORT = sshPort;
        };
        # accounts are made with `forgejo admin user create`
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };

    # for `forgejo admin`
    environment.systemPackages = [ config.services.forgejo.package ];

    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
      sshPort
    ];

    dotnix = {
      home.sites.git = { inherit port; };
      backup.paths = [ config.services.forgejo.dump.backupDir ];
    };
  };
}
