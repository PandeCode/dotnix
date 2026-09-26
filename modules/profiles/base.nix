{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.modules) mkDefault mkIf;

  cfg = config.dotnix.profiles.base;
in

{
  options.dotnix.profiles.base.enable = lib.options.mkEnableOption "what every machine of mine gets";

  config = mkIf cfg.enable {
    programs = {
      # login shells stay bash; the terminal starts fish
      fish.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      mtr.enable = true;
    };

    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    environment = {
      wordlist.enable = true;

      systemPackages = with pkgs; [
        # keep-sorted start
        ast-grep
        astroterm
        bat
        bat-extras.batdiff
        bat-extras.batman
        bat-extras.batpipe
        bat-extras.batwatch
        bc
        bonsai
        caligula
        cmatrix
        cyme
        difftastic
        duf
        dust
        expect
        fastfetch
        fd
        ffmpeg
        file
        git
        gitoxide
        glow
        gum
        htmlq
        hyperfine
        imagemagick
        imgcat
        inetutils
        jq
        just
        lm_sensors
        man-pages
        man-pages-posix
        net-tools
        nh
        nix-init
        nix-output-monitor
        nix-prefetch-github
        numbat
        nurl
        p7zip
        pastel
        pciutils
        pigz
        pinentry-curses
        poppler-utils
        progress
        psmisc
        pv
        ripgrep
        rlwrap
        socat
        systemctl-tui
        sysz
        tldr
        tmux
        tre-command
        ueberzug
        unzip
        usbutils
        wget
        xh
        xxd
        zip
        # keep-sorted end
      ];
    };

    dotnix.profiles.security.enable = mkDefault true;
  };
}
