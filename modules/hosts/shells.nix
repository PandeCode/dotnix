{
  pkgs,
  sharedConfig,
  config,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      lesspipe
      poppler-utils
    ];

    sessionVariables = {
      LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
      FZF_DEFAULT_OPTS = with pkgs.lib;
        "--color "
        + (
          concatStringsSep "," (mapAttrsToList (name: value: "${name}:${value}") (with config.lib.stylix.colors.withHashtag; {
            "bg" = base00;
            "bg+" = base01;
            "fg" = base04;
            "fg+" = base06;
            "header" = base0D;
            "hl" = base0D;
            "hl+" = base0D;
            "info" = base0A;
            "marker" = base0C;
            "pointer" = base0C;
            "prompt" = base0A;
            "spinner" = base0C;
          }))
        )
        + " --highlight-line --info=inline-right --ansi --layout=reverse --border=none --preview 'fzf-preview.sh {}'";
      FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    };
  };

  programs = let
    enable_shells = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  in rec {
    zoxide = enable_shells;
    nix-index = enable_shells;
    direnv =
      enable_shells
      // {
        nix-direnv.enable = true;
      };

    bat. enable = true;
    starship.settings = {
      enable = true;
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };

    bash = {
      enable = true;
      blesh.enable = true;
      inherit (sharedConfig) shellAliases;
      # interactiveShellInit = ''
      #   if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      #   then
      #     shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      #     exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      #   fi
      # '';
    };
    fish = {
      enable = true;
      shellAliases = sharedConfig.fishShellAliases;
      shellAbbrs = sharedConfig.fishShellAbbrs;
      interactiveShellInit =
        /*
        fish
        */
        ''
          set fish_greeting

          set -g fish_emoji_width 1
          set -g fish_ambiguous_width 1
          set -gx GPG_TTY (tty)

          set fish_cursor_default block
          set fish_cursor_insert line
          set fish_cursor_replace_one underscore
          set fish_cursor_visual block

          fish_vi_key_bindings

          function cmd
          	eval {mkdir,cd}\ $argv\;
          end
        '';
    };
  };
}
