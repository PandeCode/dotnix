# code.<domain>: vscodium in the browser, as you, on this machine's files.
# it listens on a socket only you and caddy can reach, behind the same
# password as the other protected sites. no telemetry and no ai chat
{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (config.dotnix) user;
  inherit (config.dotnix.home) theme;

  cfg = config.dotnix.services.code;

  home = config.users.users.${user}.home;
  dir = "/run/codium-server";
  socket = "${dir}/socket";

  c = theme.colors;

  # the dark or light default theme with the stylix colors on top
  colors = {
    "workbench.colorTheme" =
      if config.stylix.polarity == "light" then "Default Light Modern" else "Default Dark Modern";
    "workbench.colorCustomizations" = {
      "editor.background" = c.base00;
      "editor.foreground" = c.base05;
      "editor.lineHighlightBackground" = c.base01;
      "editor.selectionBackground" = c.base02;
      "editorCursor.foreground" = c.base05;
      "editorLineNumber.foreground" = c.base03;
      "editorLineNumber.activeForeground" = c.base04;
      "editorWidget.background" = c.base01;
      "editorGroupHeader.tabsBackground" = c.base00;
      "tab.activeBackground" = c.base00;
      "tab.inactiveBackground" = c.base01;
      "tab.activeBorderTop" = c.base0D;
      "tab.border" = c.base00;
      "sideBar.background" = c.base00;
      "sideBar.border" = c.base01;
      "sideBarSectionHeader.background" = c.base00;
      "activityBar.background" = c.base00;
      "activityBar.border" = c.base01;
      "activityBar.foreground" = c.base05;
      "activityBar.inactiveForeground" = c.base03;
      "activityBarBadge.background" = c.base0D;
      "activityBarBadge.foreground" = c.base00;
      "titleBar.activeBackground" = c.base00;
      "titleBar.border" = c.base01;
      "statusBar.background" = c.base00;
      "statusBar.border" = c.base01;
      "statusBar.foreground" = c.base04;
      "panel.background" = c.base00;
      "panel.border" = c.base01;
      "terminal.background" = c.base00;
      "terminal.foreground" = c.base05;
      "terminal.ansiBlack" = c.base00;
      "terminal.ansiRed" = c.base08;
      "terminal.ansiGreen" = c.base0B;
      "terminal.ansiYellow" = c.base0A;
      "terminal.ansiBlue" = c.base0D;
      "terminal.ansiMagenta" = c.base0E;
      "terminal.ansiCyan" = c.base0C;
      "terminal.ansiWhite" = c.base05;
      "terminal.ansiBrightBlack" = c.base03;
      "terminal.ansiBrightRed" = c.base08;
      "terminal.ansiBrightGreen" = c.base0B;
      "terminal.ansiBrightYellow" = c.base0A;
      "terminal.ansiBrightBlue" = c.base0D;
      "terminal.ansiBrightMagenta" = c.base0E;
      "terminal.ansiBrightCyan" = c.base0C;
      "terminal.ansiBrightWhite" = c.base07;
      "input.background" = c.base01;
      "input.border" = c.base02;
      "dropdown.background" = c.base01;
      "quickInput.background" = c.base01;
      "list.activeSelectionBackground" = c.base02;
      "list.hoverBackground" = c.base01;
      "list.inactiveSelectionBackground" = c.base01;
      "focusBorder" = c.base0D;
      "button.background" = c.base0D;
      "button.foreground" = c.base00;
      "badge.background" = c.base0D;
      "badge.foreground" = c.base00;
      "textLink.foreground" = c.base0D;
    };
    "editor.fontFamily" = "'${config.stylix.fonts.monospace.name}', monospace";
    "terminal.integrated.fontFamily" = "'${config.stylix.fonts.monospace.name}', monospace";
  };

  # defaults, so changing them in the settings still works
  server = pkgs.vscodium-server.override {
    settings = {
      "telemetry.telemetryLevel" = "off";
      "chat.disableAIFeatures" = true;
      "workbench.enableExperiments" = false;
      "update.mode" = "none";
      # it's your own machine, so no restricted mode on every folder
      "security.workspace.trust.enabled" = false;
    }
    // lib.attrsets.optionalAttrs (theme != null) colors;
  };
in

{
  options.dotnix.services.code.enable =
    lib.options.mkEnableOption "vscodium in the browser, at code.<domain>";

  # it is a shell as you, so without a password it doesn't run at all
  config = lib.modules.mkIf (cfg.enable && config.dotnix.home.passwordFile != null) {
    systemd.services.codium-server = {
      description = "VSCodium in the browser";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        User = user;
        WorkingDirectory = "~";
        Restart = "on-failure";
        # systemd makes the folder fresh on every start and drops it on stop,
        # so an old socket can't be left behind for the server to trip on
        RuntimeDirectory = "codium-server";
        RuntimeDirectoryMode = "0750";
        ExecStartPre = "${lib.meta.getExe' pkgs.coreutils "rm"} -f ${socket}";
        # as root (+): hand the folder and the socket to caddy's group, the
        # socket comes out as you with group users, and caddy writes to it
        ExecStartPost = "+${pkgs.writeShellScript "codium-server-socket" ''
          while [ ! -S ${socket} ]; do sleep 0.2; done
          chgrp ${config.services.caddy.group} ${dir} ${socket}
          chmod 0660 ${socket}
        ''}";
        # through a login shell, so its terminals get the path an ssh login
        # gets, like term.<domain>
        ExecStart = utils.escapeSystemdExecArgs [
          (lib.meta.getExe pkgs.bashInteractive)
          "-lc"
          (lib.strings.concatStringsSep " " [
            "exec"
            (lib.meta.getExe server)
            "--socket-path"
            socket
            # the socket's folder is the lock: only you and caddy get in
            "--without-connection-token"
            "--telemetry-level"
            "off"
            "--accept-server-license-terms"
            "--default-folder"
            home
          ])
        ];
      };
    };

    dotnix.home.sites.code = {
      inherit socket;
      protect = true;
    };
  };
}
