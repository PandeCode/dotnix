{ config, lib, ... }:

let
  cfg = config.dotnix.services.navidrome;
in

{
  options.dotnix.services.navidrome = {
    enable = lib.options.mkEnableOption "navidrome, at music.<domain>";

    musicFolder = lib.options.mkOption {
      type = lib.types.str;
      default =
        if config.dotnix.services.files.enable then
          "${config.dotnix.services.files.folder}/music"
        else
          "/srv/music";
      defaultText = lib.literalExpression ''"''${files.folder}/music" with dotnix.services.files, else "/srv/music"'';
      description = "Where the music is. Inside the shared folder, you can upload and edit it at files.<domain> and over smb.";
    };
  };

  config = lib.modules.mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings = {
        Address = "127.0.0.1";
        MusicFolder = cfg.musicFolder;
      };
    };

    # yours to fill, navidrome's to read, through the users group
    systemd.tmpfiles.rules = [ "d ${cfg.musicFolder} 0750 ${config.dotnix.user} users -" ];
    users.users.${config.services.navidrome.user}.extraGroups = [ "users" ];

    dotnix = {
      home.sites.music.port = config.services.navidrome.settings.Port;
      backup.paths = [ "/var/lib/navidrome" ];
    };
  };
}
