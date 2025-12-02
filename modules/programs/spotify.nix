{
  sharedConfig,
  pkgs,
  ...
}: {
  xdg = {
    desktopEntries = let
      p = pkgs.spotify-player;
      shared = {
        terminal = false;
        type = "Application";
        icon = "mpv";
        categories = ["Audio" "AudioVideo" "ConsoleOnly" "Music" "Player"];
      };
    in {
      "${p.pname}-${sharedConfig.terminal}" =
        shared
        // {
          name = "${p.pname} (${sharedConfig.terminal})";
          comment = p.meta.description;
          exec = "${sharedConfig.terminal} -e  ${p}/bin/${p.meta.mainProgram}";
          terminal = false;
        };
      "${p.pname}-xterm" =
        shared
        // {
          name = "${p.pname} (xterm)";
          comment = p.meta.description;
          exec = "${pkgs.xterm}/bin/${pkgs.xterm.meta.mainProgram} -e  ${p}/bin/${p.meta.mainProgram}";
        };
    };
  };
  programs.spotify-player = {
    enable = true;
    settings = {
      playback_window_position = "Top";
      copy_command = {
        command = "cs";
        args = [];
      };
      device = {
        audio_cache = true;
        normalization = true;
      };
    };
  };
  services.librespot = {
    enable = true;
    settings = {
      name = "Librespot";
      device-type = "gameconsole";
      initial-volume = 75;
      bitrate = 320;
      enable-volume-normalisation = true;
    };
  };
}
