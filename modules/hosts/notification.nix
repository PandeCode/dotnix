_: {
  systemd.user.services.checkGitStatus = {
    Service = {
      Description = "Check for unstaged Git files in a directory and notify";
      ExecStart = ''check_git_status.sh ~/dotnix && check_git_status.sh ~/.config/nvim'';
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  systemd.user.timers.checkGitStatus = {
    Timer = {
      Description = "Run Git status check at 3 PM daily";
      OnCalendar = "15:00";
      Persistent = true;
    };
    Unit = "checkGitStatus.service";
  };

  systemd.user.timers.checkGitStatus.enable = true;
}
