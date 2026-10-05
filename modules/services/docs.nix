# docs.<domain>: paperless-ngx, every paper and pdf ocr'd, tagged and
# searchable. drop files in the scan folder and they show up here
{ config, lib, ... }:

let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  inherit (config.dotnix) user;

  cfg = config.dotnix.services.docs;
in

{
  options.dotnix.services.docs = {
    enable = mkEnableOption "paperless-ngx, at docs.<domain>";

    inbox = mkOption {
      type = types.str;
      default =
        if config.dotnix.services.files.enable then
          "${config.dotnix.services.files.folder}/scan"
        else
          "/srv/scan";
      defaultText = lib.literalExpression ''"''${files.folder}/scan" with dotnix.services.files, else "/srv/scan"'';
      description = "Files put here are taken in and removed. Inside the shared folder, you can drop them in over smb.";
    };

    passwordFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Your password, read at run time, so a secret's path; the user is
        dotnix.user. It is set again when it changes. There is no app
        without it.
      '';
    };
  };

  config = lib.modules.mkIf (cfg.enable && cfg.passwordFile != null) {
    services.paperless = {
      enable = true;
      inherit (cfg) passwordFile;
      consumptionDir = cfg.inbox;
      domain = "docs.${config.dotnix.home.domain}";
      database.createLocally = true;
      # ocr stays english, its default: naming a language rebuilds it from source
      settings = {
        PAPERLESS_ADMIN_USER = user;
        # it can send your documents to a language model; off
        PAPERLESS_AI_ENABLED = false;
        # scan/school/x.pdf comes in tagged school
        PAPERLESS_CONSUMER_RECURSIVE = true;
        PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      };
    };

    # yours to drop into, paperless's to empty
    systemd.tmpfiles.settings."10-paperless".${cfg.inbox}.d = lib.modules.mkForce {
      inherit user;
      group = "users";
      mode = "2770";
    };
    users.users.${config.services.paperless.user}.extraGroups = [ "users" ];

    dotnix = {
      home.sites.docs.port = config.services.paperless.port;
      backup = {
        paths = [ config.services.paperless.dataDir ];
        databases = [ "paperless" ];
      };
    };
  };
}
