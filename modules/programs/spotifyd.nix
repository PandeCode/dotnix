{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.spotifyd;
in {
  options.spotifyd.enable = lib.mkEnableOption "enable spotifyd";

  config = lib.mkIf cfg.enable {
    programs.spotify-player = {
      enable = true;
    };

    services.spotifyd = {
      settings = {
        global = {
          username = "";
          password = "";
          device_name = "nix";
        };
      };
    };
  };
}
