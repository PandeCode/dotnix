# term.<domain>: ttyd, a shell on this machine in the browser. every tab
# joins one tmux session, so what runs there keeps running when the tab
# closes. yt-dlp saves into the shared folder
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.dotnix) user;
  inherit (config.dotnix.home) theme;

  cfg = config.dotnix.services.term;
  files = config.dotnix.services.files;

  port = 8091;
  videos = "${files.folder}/videos";

  c = theme.colors;
in

{
  options.dotnix.services.term.enable =
    lib.options.mkEnableOption "ttyd, a shell in the browser at term.<domain>";

  config = lib.modules.mkIf cfg.enable {
    services.ttyd = {
      enable = true;
      inherit user port;
      interface = "lo";
      writeable = true;
      checkOrigin = true;
      # through a login shell, for the same path an ssh login gets. the
      # service's own path is too bare for fish to load the nixos one
      entrypoint = [
        (lib.meta.getExe pkgs.bashInteractive)
        "-lc"
        "exec ${lib.meta.getExe pkgs.tmux} new-session -A -s term"
      ];
      clientOptions = lib.attrsets.optionalAttrs (theme != null) {
        fontFamily = "${theme.font}, monospace";
        theme = builtins.toJSON {
          background = c.base00;
          foreground = c.base05;
          cursor = c.base05;
          selectionBackground = c.base02;
          black = c.base00;
          red = c.base08;
          green = c.base0B;
          yellow = c.base0A;
          blue = c.base0D;
          magenta = c.base0E;
          cyan = c.base0C;
          white = c.base05;
          brightBlack = c.base03;
          brightRed = c.base08;
          brightGreen = c.base0B;
          brightYellow = c.base0A;
          brightBlue = c.base0D;
          brightMagenta = c.base0E;
          brightCyan = c.base0C;
          brightWhite = c.base07;
        };
      };
    };
    systemd.services.ttyd.serviceConfig.WorkingDirectory = "~";

    environment.systemPackages = [ pkgs.yt-dlp ];
    # plain `yt-dlp <url>` lands where files.<domain> and smb show it
    environment.etc."yt-dlp.conf" = lib.modules.mkIf files.enable {
      text = "--paths ${videos}\n";
    };
    systemd.tmpfiles.rules = lib.lists.optional files.enable "d ${videos} 0750 ${user} users -";

    dotnix.home.sites.term = {
      inherit port;
      # it is a shell as you, so it never opens without the password
      protect = true;
    };
  };
}
