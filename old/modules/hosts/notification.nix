{
  lib,
  config,
  ...
}: {
  options = {
    check_git.enable = lib.mkEnableOption "Enables checking for unstaged files in git repositories.";
    check_git.dirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["~/dotnix" "~/.config/nvim"];
      description = "Directories to check for unstaged Git files.";
    };
  };

  config = lib.mkIf config.check_git.enable {
    systemd = {
      user = {
        services.checkGitStatus = {
          Service = {
            Description = "Check for unstaged Git files in specified directories and notify.";
            ExecStart = ''${builtins.concatStringsSep " ; " (map (dir: "check_git_status.sh ${dir}") config.check_git.dirs)}'';
            StandardOutput = "journal";
            StandardError = "journal";
          };
        };

        timers.checkGitStatus = {
          Timer = {
            Description = "Run Git status check at 3 PM daily.";
            OnCalendar = "15:00";
            Persistent = true;
          };
          Unit = "checkGitStatus.service";
        };

        timers.checkGitStatus.enable = true;
      };
    };
  };
}
