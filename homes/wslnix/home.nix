{
  config,
  pkgs,
  lib,
  ...
}: let
  win_user = "pande";
in {
  imports = [
    ../../modules/programs/default.nix
    ../../modules/homes/stylix.nix
    # TODO ../../modules/theming/default.nix
    # TODO ../../modules/programs/python.nix
  ];

  stylix_home = {
    enable = true;
    dis.enable = lib.mkForce false;
  };

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      PYTHONPYCACHEPREFIX = "/home/${config.home.username}/.cache/__pycache__";

      WINHOME = "/mnt/c/Users/${win_user}";

      PING_HOST = "9.9.9.9"; # for a ping script

      # https://github.com/folke/tokyonight.nvim/blob/main/extras/fzf/tokyonight_night.sh
      FZF_DEFAULT_OPTS = "--highlight-line  --info=inline-right  --ansi  --layout=reverse  --border=none --color=bg+:#283457  --color=bg:#16161e  --color=border:#27a1b9  --color=fg:#c0caf5  --color=gutter:#16161e  --color=header:#ff9e64  --color=hl+:#2ac3de  --color=hl:#2ac3de  --color=info:#545c7e  --color=marker:#ff007c  --color=pointer:#ff007c  --color=prompt:#2ac3de  --color=query:#c0caf5:regular  --color=scrollbar:#27a1b9  --color=separator:#ff9e64  --color=spinner:#ff007c --preview 'fzf_preview.sh'";
      FORGIT_FZF_DEFAULT_OPTS = "--exact --border --cycle --reverse --height '80%'";
    };

    file = {
      ".gdbinit".source = builtins.fetchurl {
        url = "https://github.com/cyrus-and/gdb-dashboard/raw/master/.gdbinit";
        sha256 = "8bd249b8642977fd9c07a7ff5727d9de3556c48cf56712dbd23e5498cff410b2";
      };
    };

    packages = with pkgs; [
      pscircle
      xdg-utils

      ueberzug

      nh
      statix

      (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
      # spotify-player # Terminal spotify player that has feature parity with the official client https://github.com/aome510/spotify-player
      # spotifyd # Open source Spotify client running as a UNIX daemon https://spotifyd.rs/

      # mdbook # Create books from MarkDown https://github.com/rust-lang/mdBook

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
      hurl
      xh
      hyperfine

      # Eye Candy
      fastfetch
      imgcat
      hub
      bonsai
      cava
      cmatrix

      # Calculators
      numbat
      kalker
      # sc-im
    ];
  };
}
