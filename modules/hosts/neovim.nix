{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    configure = {
      customRC =
        /*
        vim
        */
        ''
          set nformats=alpha
          set conceallevel=1
          set expandtab=false
          set ci
          set pi
          set shiftwidth=4
          set tabstop=4
          set autoindent
          set backspace=indent,eol,start
          set backup=false
          set cmdheight=1
          set completeopt=menu,menuone,noselect
          set confirm
          set encoding=UTF-8
          set gdefault
          set hidden
          set hlsearch
          set ignorecase
          set inccommand=nosplit
          set incsearch
          set linebreak
          set list
          set number
          set pumblend=20
          set ruler
          set scrolloff=3
          set showcmd
          set showmatch
          set showtabline=2
          set signcolumn=yes
          set smartcase
          set splitbelow
          set synmaxcol=128
          set termguicolors
          set timeout
          set timeoutlen=1000
          set ttyfast
          set updatetime=250
          set visualbell
          set winblend=20
          set wrap
          set writebackup=false
          set wildmode=longest,list,full
          set wildmenu
          "set wildignore=*.pyc,*_build/*,**/coverage/*,**/Debug/*,**/build/*,**/node_modules/*,**/android/*,**/\ ios/*,**/.git/*

          "colorscheme tokyonight-night
        '';
      packages = {
        myVimPackage = with pkgs.vimPlugins; {
          start = [
            bufferline-nvim
            # tokyonight-nvim
            vim-cursorword
            vim-multiple-cursors
            vim-wordmotion
            lualine-nvim
          ];
        };
      };
    };
  };
}
