{
  config,
  lib,
  osConfig,
  ...
}:

let
  inherit (osConfig.dotnix) flakePath;

  abbreviations = {
    lsblk = "lsblk | bat -l conf -p";
    ps = "ps | bat -l conf -p";
    lscpu = "lscpu | bat -l cpuinfo -p";
    sensors = "sensors | bat -l cpuinfo -p";

    dirflake = "echo 'use flake' > .envrc; direnv allow";
    dirnix = "echo 'use nix' > .envrc; direnv allow";
    neo = "neovide $(fzf) 2>&1  > /dev/null & disown";
    ns = "nix-shell shell.nix --command 'fish'";
    nsp = "NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nix-shell --command 'fish' -p";

    gamescopehdr = "DXVK_HDR=1 gamescope -f --hdr-enabled -- ";
    steamhdr = "ENABLE_HDR_WSI=1 DXVK_HDR=1 DISPLAY= ";
    winehdr = "ENABLE_HDR_WSI=1 DXVK_HDR=1 DISPLAY= wine ";
    mpvhdr = "ENABLE_HDR_WSI=1 mpv --vo=gpu-next --target-colorspace-hint --gpu-api=vulkan --gpu-context=waylandvk ";

    ls = "ls --color=auto";
    sl = "ls --color=auto";
    l = "ls --color=auto -latr";

    mkdri = "mkdir";
    mkidr = "mkdir";
    mdkir = "mkdir";
    dmkir = "mkdir";
    cp = "cp -ir";
    free = "free -m";
    sizeof = "bash -c 'du -h --max-depth=0'";
    tree = "tre";

    clonec = "git clone --depth 1 --recurse-submodules --shallow-submodules --single-branch --filter=blob:none -j$(nproc) $(cso)";
    wgetc = "cso | xargs wget -c ";

    gti = "git";

    ":e" = "nvim";
    ":E" = "nvim";
    e = "nvim";
    ":q" = "exit";
    ":Q" = "exit";
    eixt = "exit";
    nivm = "nvim";
    py = "python3";

    man = "batman";
    cls = "clear";
    tls = "clear ; tmux clear-history";
    les = "less";

    mkae = "make";
  };

  aliases.j = "z";

  withShells = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
in

{
  programs = {
    fish = {
      enable = true;
      shellAbbrs = abbreviations;
      shellAliases = aliases;
      # generating them from man pages is slow
      generateCompletions = false;

      functions.cmd = "mkdir $argv; and cd $argv";

      interactiveShellInit = ''
        set fish_greeting

        set -g fish_emoji_width 1
        set -g fish_ambiguous_width 1
        set -gx GPG_TTY (tty)

        set fish_cursor_default block
        set fish_cursor_insert line
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block

        fish_vi_key_bindings
      '';
    };

    bash = {
      enable = true;
      shellAliases = abbreviations // aliases;
    };

    nushell.enable = true;

    atuin = withShells;
    carapace = withShells;
    zoxide = withShells;

    direnv = withShells // {
      nix-direnv.enable = true;
    };

    starship = withShells // {
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };

    fzf = withShells // {
      # atuin keeps ctrl-r
      historyWidget.command = "";
      defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
      defaultOptions = [
        "--highlight-line"
        "--info=inline-right"
        "--ansi"
        "--layout=reverse"
        "--border=none"
        "--preview 'fzf-preview.sh {}'"
      ];
    };

    bat.enable = true;
    lesspipe.enable = true;

    btop = {
      enable = true;
      settings = {
        proc_tree = true;
        truecolor = true;
        proc_sorting = "memory";
        proc_aggregate = true;
      };
    };

    cava.enable = true;
  };

  xdg = {
    enable = true;
    configFile."cava/shell".source = ../../config/cava/shell;
  };

  home = {
    file = {
      ".npmrc".text = "prefix=~/.npm-packages";

      ".tmux.conf".text = ''
        set -g default-shell ${lib.meta.getExe config.programs.fish.package}
        source ${flakePath}/config/tmux/.tmux.conf
      '';
    };

    sessionVariables = {
      DOTFILES = flakePath;
      GOPATH = "${config.home.homeDirectory}/go";
      GTK_USE_PORTAL = "1";
      PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/__pycache__";
      TERMINAL = config.dotnix.wm.terminal;
    };

    sessionPath = [
      "$HOME/.local/bin"
      # bin/ of a git repo, once it's marked trusted with `mkdir .git/safe`
      ".git/safe/../../bin"
      "$GOPATH/bin"
      "$HOME/.npm-packages/bin"
    ];
  };
}
