{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.hermes.nixosModules.default
  ];
  nixpkgs.config.allowUnfree = true;

  nvim = {
    enable = true;
    packageNames  = ["nvim" "nvim-rs" "nvim-cpp" "nvim-go" "nvim-web"];
  };

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [gtk3 fuse3];
    };

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

    

  environment.systemPackages = with pkgs; [
    home-manager

    gnumake

    nh

    gcc
    progress

    ueberzug

    alsa-utils
    stacer

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
    bat-extras.batgrep
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
    axel
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
