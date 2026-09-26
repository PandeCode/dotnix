{
  pkgs,
  lib,
  ...
}: {
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris
      autosub
      memo

      uosc
      # modernz
      # modernx
    ];

    extraInput = ''
      esc         quit                        #! Quit
      #           script-binding uosc/video   #! Video tracks
      # additional comments
    '';

    extraMakeWrapperArgs = [
      "--prefix"
      "LD_LIBRARY_PATH"
      ":"
      (lib.makeLibraryPath [pkgs.libaacs pkgs.libbluray])
    ];

    scriptOpts = {
      # osc = {
      #   scalewindowed = 2.0;
      #   vidscale = false;
      #   visibility = "always";
      # };
    };

    #   bindings = {
    #     "Alt+0" = "set window-scale 0.5";
    #     WHEEL_DOWN = "seek -10";
    #     WHEEL_UP = "seek 10";
    #   };
    #
    #   config = {
    #     cache-default = 4000000;
    #     force-window = true;
    #     profile = "gpu-hq";
    #     ytdl-format = "bestvideo+bestaudio";
    #   };
    #
    #   profiles = {
    #     fast = {
    #       vo = "vdpau";
    #     };
    #     "protocol.dvd" = {
    #       profile-desc = "profile for dvd:// streams";
    #       alang = "en";
    #     };
    #   };
  };
}
