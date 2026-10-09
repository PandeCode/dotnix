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
      type = types.nullOr types.str;
      default = null;
      description = "Read at run time, so a secret's path, never the store. Without it there are no backups.";
    };

    paths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Added to by the services that keep state.";
    };

    databases = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Postgres databases to dump before each backup.";
    };

    exclude = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Paths under dotnix.backup.paths to leave out.";
    };
  };

  config = lib.modules.mkIf (cfg.enable && cfg.passwordFile != null) {
    services.restic.backups.main = {
      inherit (cfg)
        repository
        passwordFile
        paths
        exclude
        ;
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

    # postgres is copied mid-write by restic; the dump is a consistent copy,
    # made before the nightly backup and uncompressed so restic can deduplicate
    services.postgresqlBackup = lib.modules.mkIf (cfg.databases != [ ]) {
      enable = true;
      inherit (cfg) databases;
      compression = "none";
      startAt = "*-*-* 23:30:00";
    };

    dotnix.backup.paths = lib.lists.optional (
      cfg.databases != [ ]
    ) config.services.postgresqlBackup.location;

    systemd.services.restic-backups-main.onFailure = lib.lists.optional (
      config.dotnix.notify.url != null
    ) "notify-failure@%n.service";
  };
}
