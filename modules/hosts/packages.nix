{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.packages;
in {
  options.packages.enable = lib.mkEnableOption "enable packages";

  config = lib.mkIf cfg.enable {
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
      gum
      television

      # Version control
      git
      subversion

      pywal
      hellwal

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
    ];
  };
}
