{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.hermes.nixosModules.default
    ./nix-ld.nix
    ./dotbox.nix
  ];
  nixpkgs.config.allowUnfree = true;

  nvim = {
    enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    light.enable = true;

    coolercontrol = {
      enable = true;
      nvidiaSupport = true;
    };

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
    pinentry

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
    zellij
    zoxide

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
    eza
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
