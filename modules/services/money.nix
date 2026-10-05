# money.<domain>: hledger-web, your plain text journal of accounts in the
# browser. the journal stays a file you can edit anywhere
{ config, lib, ... }:

let
  inherit (config.dotnix) user;

  cfg = config.dotnix.services.money;

  port = 8086;
in

{
  options.dotnix.services.money = {
    enable = lib.options.mkEnableOption "hledger-web, at money.<domain>";

    folder = lib.options.mkOption {
      type = lib.types.str;
      default =
        if config.dotnix.services.files.enable then
          "${config.dotnix.services.files.folder}/money"
        else
          "/srv/money";
      defaultText = lib.literalExpression ''"''${files.folder}/money" with dotnix.services.files, else "/srv/money"'';
      description = "Where the journal is. Inside the shared folder, you can edit it over smb and at files.<domain> too.";
    };
  };

  config = lib.modules.mkIf cfg.enable {
    services.hledger-web = {
      enable = true;
      inherit port;
      allow = "edit";
      stateDir = cfg.folder;
      journalFiles = [ "main.journal" ];
      baseUrl = "https://money.${config.dotnix.home.domain}";
    };

    # the journal is yours, so it runs as you
    systemd.services.hledger-web.serviceConfig = {
      User = lib.modules.mkForce user;
      Group = lib.modules.mkForce "users";
      UMask = "0027";
    };
    # it won't start without a journal
    systemd.tmpfiles.rules = [
      "d ${cfg.folder} 0750 ${user} users -"
      "f ${cfg.folder}/main.journal 0640 ${user} users -"
    ];

    dotnix = {
      # it has no login of its own
      home.sites.money = {
        inherit port;
        protect = true;
      };
      backup.paths = [ cfg.folder ];
    };
  };
}
