{
  pkgs,
  config,
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

    extraPackages = with pkgs; [
      (pkgs.python3.withPackages (python-pkgs:
        with python-pkgs; [
          python-lsp-server
          python-lsp-ruff
          python-lsp-black
          pyls-memestra
          pylsp-rope
        ]))

      chafa
      dwt1-shell-color-scripts
      pokemon-colorscripts-mac

      # Language Servers
      basedpyright
      emmet-ls
      glsl_analyzer
      gopls
      lua-language-server
      neocmakelsp
      nixd
      nodePackages.bash-language-server
      pylyzer
      tailwindcss-language-server
      texlab
      vim-language-server
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
      xdd
    ];
  };
}
