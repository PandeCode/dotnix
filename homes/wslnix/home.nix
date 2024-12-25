{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/programs/shells.nix
    ../../modules/programs/git.nix
  ];

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      NVIM_IMG_DIR = "/home/${config.home.username}/.config/nvim/startup_images";
      PYTHONPYCACHEPREFIX = "/home/${config.home.username}/.cache/__pycache__";

      FZF_DEFAULT_OPTS = "--highlight-line  --info=inline-right  --ansi  --layout=reverse  --border=none --color=bg+:#283457  --color=bg:#16161e  --color=border:#27a1b9  --color=fg:#c0caf5  --color=gutter:#16161e  --color=header:#ff9e64  --color=hl+:#2ac3de  --color=hl:#2ac3de  --color=info:#545c7e  --color=marker:#ff007c  --color=pointer:#ff007c  --color=prompt:#2ac3de  --color=query:#c0caf5:regular  --color=scrollbar:#27a1b9  --color=separator:#ff9e64  --color=spinner:#ff007c"; # https://github.com/folke/tokyonight.nvim/blob/main/extras/fzf/tokyonight_night.sh

      WINHOME = "/mnt/c/Users/pande";
      NVIM_ASCII_DIR = "/mnt/c/Users/pande/Pictures/nvim";
    };

    file = {
      ".gdbinit".source = builtins.fetchurl {
        url = "https://github.com/cyrus-and/gdb-dashboard/raw/master/.gdbinit";
        sha256 = "8bd249b8642977fd9c07a7ff5727d9de3556c48cf56712dbd23e5498cff410b2";
      };
      ".cargo/config.toml".text = ''
        [build]
        target-dir = "/home/shawn/.cache/target"
        rustc-wrapper = "sccache"

        [target.x86_64-unknown-linux-gnu]
        linker = "clang"
        rustflags = ["-C", "link-arg=--ld-path=mold"]
      '';
    };

    packages = with pkgs; [
      pscircle
      nh
      statix

      # hasekll
      # cabal-install # The command-line interface for Cabal and Hackage https://hackage.haskell.org/package/cabal-install
      # ghc # Glasgow Haskell Compiler http://haskell.org/ghc
      # haskell-language-server # LSP server for GHC https://hackage.haskell.org/package/haskell-language-server
      # stack # The Haskell Tool Stack https://hackage.haskell.org/package/stack
      # aspell # Spell checker for many languages http://aspell.net/
      # (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })home
      # spotify-player # Terminal spotify player that has feature parity with the official client https://github.com/aome510/spotify-player
      # spotifyd # Open source Spotify client running as a UNIX daemon https://spotifyd.rs/

      # mdbook # Create books from MarkDown https://github.com/rust-lang/mdBook

      silicon # Create beautiful image of your source code https://github.com/Aloxaf/silicon
      glow # Render markdown on the CLI, with pizzazz! https://github.com/charmbracelet/glow
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

      tree-sitter

      # LSPs
      nixd
      vim-language-server # VImScript language server, LSP for vim script
      yaml-language-server # Language Server for YAML Files
      tailwindcss-language-server # Intelligent Tailwind CSS tooling for Visual Studio code
      vscode-langservers-extracted
      pyright # Type checker for the Python language https://github.com/Microsoft/pyright
      # basedpyright

      ctags # Tool for fast source code browsing (exuberant ctags) https://ctags.sourceforge.net/
      emmet-ls # Emmet support based on LSP https://github.com/aca/emmet-ls
      lua-language-server # Language server that offers Lua language support https://github.com/luals/lua-language-server
      neocmakelsp # CMake lsp based on tower-lsp and treesitter https://github.com/Decodetalkers/neocmakelsp
      nil # Yet another language server for Nix https://github.com/oxalica/nil
      nodePackages.bash-language-server
      ra-multiplex # Multiplexer for rust-analyzer https://github.com/pr2502/ra-multiplex
      glsl_analyzer
      markdownlint-cli

      # Formatters
      stylua
      black # Uncompromising Python code formatter https://github.com/psf/black
      alejandra # An opinionated formatter for Nix https://hackage.haskell.org/package/nixfmt
      nodePackages.lua-fmt # Format Lua code https://github.com/trixnz/lua-fmt
      nodePackages.prettier # An opinionated `toml` formatter plugin for Prettier https://github.com/un-ts/prettier/tree/master/packages/prettier
      xxd # Most popular clone of the VI editor http://www.vim.org

      # Better Tools
      axel # parallel downloads
      tldr
      eza
      difftastic # Syntax-aware diff https://github.com/Wilfred/difftastic
      just # better make
      duf # better df
      hurl # Command line tool that performs HTTP requests defined in a simple plain text format https://hurl.dev/
      hyperfine # Command-line benchmarking tool https://github.com/sharkdp/hyperfine
      # lldb # Next-generation high-performance debugger https://lldb.llvm.org/
      # cgdb # Curses interface to gdb https://cgdb.github.io/
      gdbgui

      # Eye Candy
      fastfetch
      chafa
      hub
      dwt1-shell-color-scripts
      cowsay
      bonsai
      cava
      cmatrix
      pokemon-colorscripts-mac

      # Calculators
      numbat
      kalker
      # sc-im

      # Pentesting
      # whois # Intelligent WHOIS client from Debian https://packages.qa.debian.org/w/whois.html
      # holehe # CLI to check if the mail is used on different sites https://github.com/megadose/holehe
      # lemmeknow # Tool to identify anything https://github.com/swanandx/lemmeknow
      # nmap # Free and open source utility for network discovery and security auditing http://www.nmap.org
      # rustscan # Faster Nmap Scanning with Rust https://github.com/RustScan/RustScan
      # rustcat # Port listener and reverse shell https://github.com/robiot/rustcat
      # binwalk # Tool for searching a given binary image for embedded files https://github.com/OSPG/binwalk
      # aircrack-ng
      # john # John the Ripper password cracker https://github.com/openwall/john/
      # sshs # Terminal user interface for SSH https://github.com/quantumsheep/sshs
      # # qemu_full # Too big
      # nasm
      # radare2 # UNIX-like reverse engineering framework and command-line toolset https://radare.org

      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];
  };
}
