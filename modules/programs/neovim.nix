{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  home = let
    win_user = "pande";
  in {
    sessionVariables = {
      NVIM_ASCII_DIR = "/home/${config.home.username}/.config/nvim/startup_images";
      NVIM_IMG_DIR = "/mnt/c/Users/${win_user}/Pictures/nvim";
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

    extraPackages =
      (with pkgs.vimPlugins.nvim-treesitter-parsers; [asm bash c comment cpp csv fish git_config git_rebase gitattributes gitcommit gitignore glsl heex html javascript json json5 kdl latex lua luadoc luau make markdown markdown_inline nix nu powershell python query rust tsx typescript vim vimdoc scss graphql fennel])
      ++ (with pkgs; [
        (pkgs.python3.withPackages (python-pkgs:
          with python-pkgs; [
            python-lsp-server
            python-lsp-ruff
            python-lsp-black
            pyls-memestra
            pylsp-rope
          ]))

        mpls

        # (import ../../derivations/codelldb.nix {inherit pkgs;})
        # (import ../../derivations/cpptools.nix {inherit pkgs;})

        fennel-ls
        fnlfmt

        haskell-language-server
        tex-fmt

        chafa
        dwt1-shell-color-scripts
        pokemon-colorscripts-mac

        ghostscript_headless

        # Language Servers
        # basedpyright
        emmet-ls
        glsl_analyzer
        gopls
        lua-language-server
        neocmakelsp
        nixd
        clang-tools
        nil
        nodePackages.bash-language-server
        pylyzer
        tailwindcss-language-server
        texlab
        # vim-language-server
        vscode-langservers-extracted
        yaml-language-server

        # Formatters
        alejandra
        black
        nodePackages.prettier
        prettierd
        shfmt
        stylua

        # Linters
        markdownlint-cli

        # Utilities
        aspell
        ctags
        lazygit
        ra-multiplex
        tree-sitter
        xxd
      ]);
  };
}
