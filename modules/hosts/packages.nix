{
  pkgs,
  inputs,
  sharedConfig,
  ...
}: {
  imports = [
    inputs.hermes.nixosModules.default
    ./nix-ld.nix
    ./dotbox.nix
  ];
  nixpkgs.config.allowUnfree = true;

  nvim.enable = true;
  system.userActivationScripts = {
    emmyLua = {
      text = ''
        cd /home/${sharedConfig.user}
        nvim --cmd 'autocmd VimEnter * lua rewriteEmmyLuaJsonExit()'
      '';
    };
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    light.enable = true;

    coolercontrol.enable = true;
    mtr.enable = true;
  };

  services.xserver.wacom.enable = true;
  hardware = {
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    # to make nix-shell faster but not pollute my path when i dont need them
    (stdenvNoCC.mkDerivation {
      pname = "ensure-installed";
      version = "0.0.0";
      buildInputs = [clang clang-tools cargo gdb bear];
      src = null;
      dontUnpack = true;
      dontBuild = true;
      dontFixup = true;
      installPhase = ''
        mkdir -p $out/bin;
        echo echo Ensure Install > $out/bin/.ensure-install;
        chmod +x $out/bin/.ensure-install;
      '';
    })

    man-pages
    man-pages-posix

    home-manager
    sops

    appimage-run

    xf86_input_wacom
    opentabletdriver

    gnumake

    glib

    nh

    gcc
    progress

    ueberzug

    alsa-utils
    # stacer

    gnupg

    pinentry-curses
    nix-prefetch-github
    nix-init
    nurl

    nh
    nix-output-monitor

    busybox
    inetutils
    wget

    bat
    bat-extras.batpipe
    bat-extras.batman
    bat-extras.batdiff
    # bat-extras.batgrep
    bat-extras.batwatch

    expect # unbuffer command

    jq
    pipr
    htmlq
    p7zip

    fish
    tmux
    zoxide

    zip
    rlwrap

    fzf
    glow
    gum

    git
    subversion

    pulseaudio

    ffmpeg
    mpv
    nsxiv
    pqiv

    systemctl-tui
    sysz

    caligula
    astroterm
    pastel

    imagemagick

    tre-command
    ast-grep
    ripgrep
    fd

    gh
    delta

    pre-commit
    lazygit
    gitoxide
    xxd

    # Better Tools
    # axel
    file
    tldr
    difftastic
    just
    duf
    dust
    # hurl
    xh
    hyperfine
    socat

    newsboat

    # Eye Candy
    fastfetch
    imgcat
    hub
    bonsai
    cmatrix

    # Calculators
    numbat
    # kalker
    # sc-im

    nodejs

    luajit

    (python3.withPackages (python-pkgs:
      with python-pkgs; [
        pygments
        requests

        pandas
        numpy
        scipy
        matplotlib
        uncertainties
        sympy
        ds4drv

        youtube-transcript-api
        # pwntools
      ]))
  ];
}
