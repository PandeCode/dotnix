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

    before = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "forgejo-dump" ];
      description = "Services that run right before each backup, like dumps, so it has their newest output.";
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
    # uncompressed so restic can deduplicate
    services.postgresqlBackup = lib.modules.mkIf (cfg.databases != [ ]) {
      enable = true;
      inherit (cfg) databases;
      compression = "none";
      # run by the backup instead
      startAt = [ ];
    };

    dotnix = {
      backup = {
        before = map (db: "postgresqlBackup-${db}") cfg.databases;
        paths = lib.lists.optional (cfg.databases != [ ]) config.services.postgresqlBackup.location;
      };
      notify.units = [ "restic-backups-main" ] ++ cfg.before;
    };

    # a failed dump is reported on its own, and the backup still runs. with
    # the repository's drive missing it fails, instead of starting a new one
    systemd.services.restic-backups-main = {
      wants = map (unit: "${unit}.service") cfg.before;
      after = map (unit: "${unit}.service") cfg.before;
      unitConfig.RequiresMountsFor = lib.lists.optional (lib.strings.hasPrefix "/" cfg.repository) cfg.repository;
    };
  };
}
