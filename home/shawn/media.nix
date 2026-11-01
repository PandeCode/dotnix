{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  inherit (config.dotnix.wm) terminal;

  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  spotify-player = config.programs.spotify-player.package;
  inTerminal = term: {
    name = "${spotify-player.pname} (${term})";
    comment = spotify-player.meta.description;
    exec = "${term} -e ${lib.meta.getExe spotify-player}";
    icon = "mpv";
    terminal = false;
    type = "Application";
    categories = [
      "Audio"
      "AudioVideo"
      "ConsoleOnly"
      "Music"
      "Player"
    ];
  };
in

{
  imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

  config = lib.modules.mkIf osConfig.dotnix.profiles.apps.enable {
    programs = {
      mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          autosub
          memo
          mpris
          uosc
        ];
        extraInput = ''
          esc quit #! Quit
        '';
        # blu-ray playback
        extraMakeWrapperArgs = [
          "--prefix"
          "LD_LIBRARY_PATH"
          ":"
          (lib.strings.makeLibraryPath [
            pkgs.libaacs
            pkgs.libbluray
          ])
        ];
      };

      spotify-player = {
        enable = true;
        settings = {
          playback_window_position = "Top";
          copy_command = {
            command = "cs";
            args = [ ];
          };
          device = {
            audio_cache = true;
            normalization = true;
          };
        };
      };

      spicetify = {
        enable = true;
        enabledCustomApps = with spicePkgs.apps; [
          lyricsPlus
          marketplace
          ncsVisualizer
          newReleases
          {
            name = "eternal-jukebox";
            src = pkgs.fetchFromGitHub {
              owner = "Pithaya";
              repo = "spicetify-apps-dist";
              rev = "ab6d4440bcbf0ad0060c5a19581b43605720f113";
              hash = "sha256-4P8wHBvjzjRvzhBTU8zVD+2QCZAw5A9BgmYiG59UcQA=";
            };
          }
        ];
        enabledExtensions = with spicePkgs.extensions; [
          adblock
          hidePodcasts
          # shuffle+
          shuffle
        ];
      };

      newsboat = {
        enable = true;
        autoFetchArticles.enable = true;
        extraConfig = builtins.readFile ../../config/newsboat/config;
        urls = import ./feeds.nix;
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

    xdg.desktopEntries = {
      "${spotify-player.pname}-${terminal}" = inTerminal terminal;
      "${spotify-player.pname}-xterm" = inTerminal (lib.meta.getExe pkgs.xterm);
    };

    home.packages = with pkgs; [
      anime4k
      nsxiv
      pqiv
      vlc
    ];
  };
}
