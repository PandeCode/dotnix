{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./shells.nix
    ./zellij.nix
    ./bin.nix
    ./tools.nix

    ./neovim.nix
    ./spicetify.nix
    ./wezterm.nix

    ./git.nix
  ];
  disabledModules = [
  ];

  bin.enable = true;
  git.enable = true;
  tools.enable = true;

  neovim.enable = lib.mkDefault true;

  shells.enable = lib.mkDefault true;
  zellij.enable = lib.mkDefault true;

  home = rec {
    sessionVariables = {
      PYTHONPYCACHEPREFIX = "/home/${config.home.username}/.cache/__pycache__";
      GOPATH = "/home/${config.home.username}/go";
      DOTFILES = "/home/${config.home.username}/dotnix";
    };

    sessionPath = [
      "$DOTFILES/bin"
      "$HOME/.local/bin"
      ".git/safe/../../bin"
      "${sessionVariables.GOPATH}/bin"
    ];

    file = {
      ".gdbinit".source = builtins.fetchurl {
        url = "https://github.com/cyrus-and/gdb-dashboard/raw/master/.gdbinit";
        sha256 = "8bd249b8642977fd9c07a7ff5727d9de3556c48cf56712dbd23e5498cff410b2";
      };
    };

    packages = with pkgs; [
      gcc
      progress

      pscircle
      xdg-utils

      ueberzug

      nh
      statix

      # spotify-player # Terminal spotify player that has feature parity with the official client https://github.com/aome510/spotify-player
      # spotifyd # Open source Spotify client running as a UNIX daemon https://spotifyd.rs/

      # silicon # Create beautiful image of your source code https://github.com/Aloxaf/silicon
      # glow # Render markdown on the CLI, with pizzazz! https://github.com/charmbracelet/glow
      # charm-freeze # Tool to generate images of code and terminal output https://github.com/charmbracelet/freeze
      # goshot

      shc # Shell Script Compiler https://neurobin.org/projects/softwares/unix/shc/

      imagemagick

      glslviewer

      ncdu
      # fdupes
      # nnn
      # yazi

      tre-command
      libresprite
      ast-grep
      ripgrep

      nix-search-cli

      # git
      gh
      delta
      commitizen
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
      hurl
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
      kalker
      # sc-im
    ];
  };
}
