# one nightly restic snapshot of every path services add to
# dotnix.backup.paths
{ config, lib, ... }:

let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;

  cfg = config.dotnix.backup;
in

{
  options.dotnix.backup = {
    enable = mkEnableOption "nightly restic backups";

    repository = mkOption {
      type = types.str;
      example = "/srv/backup";
    };

    passwordFile = mkOption {
      type = types.str;
      description = "Read at run time, so a secret's path, never the store.";
    };

    paths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Added to by the services that keep state.";
    };
  };

  config = lib.modules.mkIf cfg.enable {
    services.restic.backups.main = {
      inherit (cfg) repository passwordFile paths;
      initialize = true;
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
      runCheck = true;
    };

    systemd.services.restic-backups-main.onFailure = lib.lists.optional (
      config.dotnix.notify.url != null
    ) "notify-failure@%n.service";
  };
}
