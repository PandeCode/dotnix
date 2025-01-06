{
  pkgs,
  # nixpkgs-stable,
  # config, lib,  inputs, pkgs-unstable,
  ...
}:
# let stable = import nixpkgs-stable {}; in
{
  imports = [
    ../../modules/hosts/default.nix
  ];

  nix = {
    settings = {
      trusted-users = ["root" "shawn"];
    };
  };

  systemd.services."user-runtime-dir@" = {
    overrideStrategy = "asDropin";
    unitConfig.ConditionPathExists = "!/run/user/%i";
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [gtk3];
  };

  environment.variables = {
    EDITOR = "nvim";
  };

  environment.systemPackages = with pkgs; [
    home-manager

    # Editors
    neovim

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
    p7zip
    gdb
    appimage-run

    # Shells and terminal tools
    fish
    nushell
    zellij
    zoxide
    carapace
    starship
    atuin
    xclip
    btop
    fzf

    # Version control
    git
    subversion

    # Python packages
    (pkgs.python3.withPackages (python-pkgs:
      with python-pkgs; [
        python-lsp-server
        python-lsp-ruff
        python-lsp-black
        pyls-memestra
        pylsp-rope

        fire
        pygments
        pywal
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

    # Node.js
    nodejs

    # Multimedia
    pulseaudio
    ffmpeg
    # install mpv to ensure display manager gets installed as a dependency
    mpv
    sxiv # Simple X Image Viewer https://github.com/muennich/sxiv
  ];
}
