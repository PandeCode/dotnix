{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [gtk3 fuse3];
    };
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs; [
    pass
    qtpass
    gnupg
    pinentry

    nix-prefetch-github
    nix-init
    nurl

    nix-output-monitor
    deadnix
    statix
    nix-tree

    home-manager

    # Editors
    neovim

    # nvtop

    # Build tools
    gnumake

    # Utilities
    busybox
    inetutils
    wget
    bat
    expect # unbuffer command
    tree-sitter
    jq
    htmlq
    p7zip
    gdb
    appimage-run

    # Shells and terminal tools
    fish
    zellij
    zoxide
    carapace
    starship
    atuin
    xclip
    fzf
    glow
    gum
    television
    fuzzel

    slurp
    grim

    # Version control
    git
    subversion

    pywal
    hellwal

    (aspellWithDicts
      (dicts: with dicts; [de en en-computers en-science es fr la]))

    # Python packages
    (pkgs.python3.withPackages (python-pkgs:
      with python-pkgs; [
        fire
        pygments
        requests
        # Physics Stuff
        pandas
        numpy
        scipy
        matplotlib
        uncertainties
        sympy
        # pwntools
      ]))

    nodejs

    pulseaudio
    ffmpeg
    mpv
    nsxiv
    pqiv
  ];
}
