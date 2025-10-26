{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./shells.nix
    ./zellij.nix

    ./spicetify.nix
    ./wezterm.nix

    ./git.nix
  ];

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
      zoom-us
      kicad
      opencode

      deskreen

      pscircle
      xdg-utils

      statix

      spotifyd

      (callPackage ../../derivations/notify-send-py.nix {})

      silicon

      ncdu

      dejsonlz4

      proselint

      gobang
      sqlite
      nix-search-cli

      pscircle

      (tesseract.override {
        enableLanguages = ["eng"];
      })
    ];
  };
}
