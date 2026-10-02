{ config, lib, ... }:

let
  cfg = config.dotnix.services.navidrome;
in

{
  options.dotnix.services.navidrome = {
    enable = lib.options.mkEnableOption "navidrome, at music.<domain>";

    musicFolder = lib.options.mkOption {
      type = lib.types.str;
      default = "/srv/music";
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

    # yours to fill, navidrome's to read
    systemd.tmpfiles.rules = [ "d ${cfg.musicFolder} 0755 ${config.dotnix.user} users -" ];

    dotnix.home.sites.music.port = config.services.navidrome.settings.Port;
  };
}
