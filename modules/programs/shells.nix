{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./fzf.nix];

  xdg.configFile = {
    "cava/shell".text = builtins.readFile ../../config/cava/shell;
  };

  programs = let
    enable_shells = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
    sharedShellAliases =
      {
        neo = "neovide (fzf) 2>&1  > /dev/null & disown";
        ns = "nix-shell shell.nix --command 'fish'";
        nsp = "nix-shell --command 'fish' -p";

        nix-del = "nix-store --delete";
        nix-q = "nix-store --query --referrers";
        nix-qr = "nix-store --query --roots";

        nh-h = "nh home switch ~/dotnix -- --show-trace";
        nh-o = "nh os switch   ~/dotnix  -- --show-trace";

        nh-hl = "nh home switch ~/dotnix -v -- --show-trace -vL";
        nh-ol = "nh os switch   ~/dotnix -v -- --show-trace -vL";

        nfu = "nix flake update";
        update = "sudo : ; cd ~/dotnix && nix flake update && nh-ol && nh-hl";

        gamescopehdr = "DXVK_HDR=1 gamescope -f --hdr-enabled -- ";
        steamhdr = "ENABLE_HDR_WSI=1 DXVK_HDR=1 DISPLAY= ";
        winehdr = "ENABLE_HDR_WSI=1 DXVK_HDR=1 DISPLAY= wine ";
        mpvhdr = "ENABLE_HDR_WSI=1 mpv --vo=gpu-next --target-colorspace-hint --gpu-api=vulkan --gpu-context=waylandvk ";

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

        clonec = "cso | xargs git clone --depth 1";
        wgetc = "cso | xargs wget -c ";

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
        ff = "fzf --print0 | xargs -0 -o nvim";
        ":q" = "exit";
        eixt = "exit";
        f = "fuck";
        nivm = "nvim";
        py = "python3";

        cls = "clear";
        tls = "clear";
        cmb = "cmake --build Debug/";
        cmc = "rm -fr CMakeCache.txt CMakeFiles Debug/ compile_commands.json";
      }
      # // pkgs.lib.if config.isWindows (
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
        # fish
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

    bash = {
      enable = true;
      shellAliases = sharedShellAliases;
    };

    nushell = {
      enable = true;
      shellAliases = sharedShellAliases;
      configFile.source = ../../config/nushell/config.nu;
    };

    pay-respects = enable_shells;
    atuin = enable_shells;
    carapace = enable_shells;
    zoxide = enable_shells;
    nix-index = builtins.removeAttrs enable_shells ["enableNushellIntegration"];
    command-not-found.enable = false;

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

    btop = {
      enable = true;
      settings = {
        proc_tree = true;
        truecolor = true;
        proc_sorting = "memory";
        proc_aggregate = true;
      };
    };

    cava = {
      enable = true;
    };
  };
}
