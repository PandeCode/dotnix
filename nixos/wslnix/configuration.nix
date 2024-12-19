# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# https://github.com/nix-community/NixOS-WSL
{
  config,
  lib,
  pkgs,
  inputs,
  pkgs-unstable,
  ...
}: let
  unstable = import <nixos-unstable> {};
in {
  imports = [<nixos-wsl/modules> <home-manager/nixos>];

  system.stateVersion = "24.11";

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # free up to 1GiB whenever there is less than 100MiB left
  nix.extraOptions = ''    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}'';

  nix.optimise.automatic = true;
  nix.optimise.dates = ["03:45"];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
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

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    gtk3
  ];

  environment.variables = {
    EDITOR = "nvim";
    WINHOME = /mnt/c/Users/pande;
    NVIM_ASCII_DIR = /home/nixos/.config/nvim/startup_images;
    NVIM_IMG_DIR = /mnt/c/Users/pande/Pictures/nvim;
  };

  environment.systemPackages = with pkgs; [
    unstable.neovim

    home-manager

    gnumake

    busybox
    inetutils

    fish
    nushell
    zellij
    zoxide

    carapace

    wget

    bat

    git
    subversion
    starship

    atuin
    xclip

    btop
    fzf

    expect # unbuffer command

    tree-sitter

    (pkgs.python3.withPackages (python-pkgs:
      with python-pkgs; [
        # pynvim

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

    nodejs

    jq
    p7zip
    gdb

    appimage-run

    pulseaudio
    ffmpeg

    # install mpv to ensure display manager gets installed as a dependancy
    mpv
    sxiv # Simple X Image Viewer https://github.com/muennich/sxiv
  ];
}
