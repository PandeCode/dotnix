{
  config,
  lib,
  osConfig,
  ...
}:

let
  inherit (osConfig.dotnix) flakePath;

  # these print through bat, as functions so typed arguments reach them
  paged = {
    lsblk = "conf";
    ps = "conf";
    lscpu = "cpuinfo";
    sensors = "cpuinfo";
  };

  abbreviations = {
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
    sizeof = "du -sh";
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

      functions = {
        cmd = "mkdir $argv; and cd $argv";
      }
      // lib.attrsets.mapAttrs (name: lang: "command ${name} $argv | bat -l ${lang} -p") paged;

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
      initExtra = lib.strings.concatLines (
        lib.attrsets.mapAttrsToList (
          name: lang: ''${name}() { command ${name} "$@" | bat -l ${lang} -p; }''
        ) paged
      );
    };

    atuin = withShells // {
      # the sync server on the home server, once its certificates are trusted
      settings = lib.modules.mkIf (osConfig.dotnix.home.ca != null) {
        sync_address = "https://atuin.${osConfig.dotnix.home.domain}";
        auto_sync = true;
        sync_frequency = "5m";
      };
    };
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
    # what `go telemetry off` writes, so go and gopls neither count nor ask
    configFile."go/telemetry/mode".text = "off\n";
  };

  home = {
    file = {
      # no registry lookups for a newer npm
      ".npmrc".text = ''
        prefix=~/.npm-packages
        update-notifier=false
      '';

      ".tmux.conf".text = ''
        set -g default-shell ${lib.meta.getExe config.programs.fish.package}
        source ${flakePath}/config/tmux/.tmux.conf
      '';
    };

    sessionVariables = {
      DOTFILES = flakePath;
      # omnisharp runs the dotnet cli, which reports usage otherwise; other
      # tools honor the generic one
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";
      DO_NOT_TRACK = "1";
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
