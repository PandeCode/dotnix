{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./fzf.nix];
  options = {
    shells.enable = lib.mkEnableOption "enables shells";
  };
  config = lib.mkIf config.shells.enable {
    fzf.enable = true;

    programs = let
      enable_shells = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
      };
      sharedShellAliases =
        {
          df = "duf";
          du = "dust";
          ls = "eza";
          sl = "eza";
          l = "eza -la";
          j = "z";

          mkdir = "mkdir";
          mkdri = "mkdir";
          mkidr = "mkdir";
          mdkir = "mkdir";
          dmkir = "mkdir";
          cp = "cp -ir";
          free = "free -m";
          sizeof = "bash -c 'du -h --max-depth=0'";
          tree = "tre";

          win = "cd /mnt/c/Users/pande";
          windev = "cd /mnt/c/Users/pande/dev";
          windl = "cd /mnt/c/Users/pande/Downloads";

          cs = "xclip -selection clipboard";
          cso = "xclip -selection clipboard -o";
          clonec = "xclip -selection clipboard -o | xargs git clone --depth 1";
          wgetc = "xclip -selection clipboard -o | xargs wget -c ";

          # Git operations
          pre = "pre-commit";
          commit = "cz commit";
          gti = "git";
          add = "git add";
          psuh = "git push";
          push = "git push";

          # Shell commands
          ":e" = "nvim";
          e = "nvim";
          ff = "nvim (fzf)";
          ":q" = "exit";
          eixt = "exit";
          f = "fuck";
          nivm = "nvim";
          np = "nano -w PKGBUILD";
          ns = "nix-shell shell.nix --command 'fish'";
          nsp = "nix-shell --command 'fish' -p";
          py = "python3";

          cls = "clear";
          tls = "clear";
          cmb = "cmake --build Debug/";
          cmc = "rm -fr CMakeCache.txt CMakeFiles Debug/ compile_commands.json";
        }
        # // (
        #   if config.wsl.enable
        #   then {
        #     pwsh = "pwsh.exe";
        #     wsl = "wsl.exe";
        #     neovide = "neovide.exe --wsl";
        #     taskkill = "taskkill.exe /F /IM";
        #     winget = "winget.exe";
        #   }
        #   else {}
        # )
        ;
    in {
      bat = {
        enable = true;
        config = {
          pager = "less -FR";
          # theme = "tokyonight_night";
        };
        # themes = {
        #   tokyonight_night = {
        #     src = builtins.fetchurl {
        #       url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/054790b8676d0c561b22320d4b5ab3ef175f7445/extras/sublime/tokyonight_night.tmTheme";
        #       sha256 = "955c14a16b04917428ffa8b567e2d3760f872f1044a1ad157857001274dceecd";
        #     };
        #   };
        # };
      };
      fish = {
        enable = true;
        shellAliases = sharedShellAliases;
        plugins = [
          {
            name = "forgit";
            inherit (pkgs.fishPlugins.forgit) src;
          }
        ];

        interactiveShellInit =
          /*
          fish
          */
          ''
            set fish_greeting
            set -g fish_emoji_width 1
            set -g fish_ambiguous_width 1
            set -gx GPG_TTY (tty)
            function cmd
            	eval {mkdir,cd}\ $argv\;
            end
          '';
      };

      bash = {
        enable = true;
        shellAliases = sharedShellAliases;
      };
      nushell = {
        enable = true;
        shellAliases = sharedShellAliases;
        configFile.source = ../../config/nushell/config.nu;
      };

      thefuck = enable_shells;
      atuin = enable_shells;
      carapace = enable_shells;
      zoxide = enable_shells;

      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableNushellIntegration = true;
        nix-direnv.enable = true;
      };

      starship =
        enable_shells
        // {
          settings = {
            add_newline = true;
            character = {
              success_symbol = "[➜](bold green)";
              error_symbol = "[➜](bold red)";
            };
          };
        };
    };
  };
}
