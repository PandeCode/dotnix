{sharedConfig, ...}: {
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
