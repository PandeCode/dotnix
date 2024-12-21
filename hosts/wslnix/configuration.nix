{
  pkgs,
  nixpkgs-stable,
  # config, lib,  inputs, pkgs-unstable,
  ...
}:
# let stable = import nixpkgs-stable {}; in
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "nixos"];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    optimise = {
      automatic = true;
      dates = ["03:45"];
    };

    # free up to 1GiB whenever there is less than 100MiB left
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}'';
  };

  systemd.services."user-runtime-dir@" = {
    overrideStrategy = "asDropin";
    unitConfig.ConditionPathExists = "!/run/user/%i";
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [gtk3];
  };

  environment.variables = {
    EDITOR = "nvim";
    NVIM_ASCII_DIR = "/home/nixos/.config/nvim/startup_images";
    NVIM_IMG_DIR = "/mnt/c/Users/pande/Pictures/nvim";
    WINHOME = "/mnt/c/Users/pande";
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

    cachix
  ];
}
