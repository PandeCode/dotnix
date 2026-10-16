# the desktop you are logged into, over vnc on tailscale only. it shows the
# x session that is already running, not a new one, so it is there only
# while you are logged in. `vncviewer <machine>` from any of your machines
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix) user;

  cfg = config.dotnix.services.screen;

  port = 5900;
  passwd = "/run/screen-password/passwd";
in

{
  options.dotnix.services.screen.enable =
    lib.options.mkEnableOption "x0vncserver, the logged-in x desktop over vnc";

  # your desktop, so without a password it doesn't run at all
  config = lib.modules.mkIf (cfg.enable && config.dotnix.home.passwordFile != null) {
    # vnc wants the password in its own file, readable by the server, which
    # runs as you. vnc only looks at the first 8 characters
    systemd.services.screen-password = {
      description = "Turn dotnix.home.passwordFile into a vnc password file";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = user;
        RuntimeDirectory = "screen-password";
        RuntimeDirectoryMode = "0700";
        LoadCredential = "password:${config.dotnix.home.passwordFile}";
      };
      # it reads one line and sops leaves the newline off
      script = ''
        { cat "$CREDENTIALS_DIRECTORY/password"; echo; } | ${pkgs.tigervnc}/bin/vncpasswd -f >${passwd}
      '';
    };

    # starts and stops with the x session, which hands it DISPLAY
    systemd.user.services.screen = {
      description = "Share the x desktop over vnc";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      unitConfig.ConditionUser = user;
      serviceConfig = {
        ExecStart = lib.strings.escapeShellArgs [
          "${pkgs.tigervnc}/bin/x0vncserver"
          "-rfbport"
          port
          "-rfbauth"
          passwd
          "-SecurityTypes"
          "VncAuth"
          # a second viewer joins instead of kicking the first
          "-AlwaysShared"
        ];
        Restart = "on-failure";
      };
    };

    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
      port
    ];
  };
}
