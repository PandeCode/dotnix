{
  config,
  lib,
  ...
}:
let
  cfg = config.dotnix.niri;
in
{
  options.dotnix.niri = {
    enable = lib.mkEnableOption "niri user config";

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "config.kdl, copied into the store.";
    };

    liveConfigDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/home/me/dotnix/config/niri";
      description = ''
        Absolute path linked to ~/.config/niri outside the store, so edits
        apply without a switch.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.configFile == null || cfg.liveConfigDir == null;
        message = "dotnix.niri: set configFile or liveConfigDir, not both";
      }
    ];

    xdg.configFile."niri/config.kdl" = lib.mkIf (cfg.configFile != null) {
      source = cfg.configFile;
    };

    xdg.configFile."niri" = lib.mkIf (cfg.liveConfigDir != null) {
      source = config.lib.file.mkOutOfStoreSymlink cfg.liveConfigDir;
    };
  };
}
