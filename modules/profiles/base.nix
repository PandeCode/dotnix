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
    time.timeZone = mkDefault "America/Toronto";

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = lib.attrsets.genAttrs [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MONETARY"
        "LC_NAME"
        "LC_NUMERIC"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
      ] (_: "en_US.UTF-8");
    };

    networking.networkmanager = {
      enable = true;
      plugins = [ pkgs.networkmanager-openvpn ];
    };

    # the way between my machines, home or not
    services.tailscale.enable = mkDefault true;

    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = true;
    systemd.oomd.enable = true;

    programs =
      let
        nixd.nixos = ''(builtins.getFlake "${config.dotnix.flakePath}").nixosConfigurations.${config.networking.hostName}.options'';
      in
      {
        hermes = {
          enable = true;
          defaultEditor = true;
          inherit nixd;
        };

        libys = {
          enable = mkDefault true;
          inherit nixd;
        };

        nix-index-database.comma.enable = true;

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
