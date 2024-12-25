{
  # config,
  pkgs,
  ...
}: {
  home.file.".config/zellij/config.kdl".source = ../../config/zellij/config.kdl;

  programs = let
    inherit (pkgs.lib) mergeAttrs;
    enable_shells = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
    envs = {
    };
    sharedShellAliases = {
      # File operations
      mkdir = "mkdir";
      mkdri = "mkdir";
      mkidr = "mkdir";
      mdkir = "mkdir";
      dmkir = "mkdir";
      cp = "cp -ir";
      df = "df -h";
      free = "free -m";
      sizeof = "du -h --max-depth=0";
      sl = "ls";
      l = "ls -la";
      tree = "tre";
      more = "less";

      # Navigation
      win = "cd /mnt/c/Users/pande";
      windev = "cd /mnt/c/Users/pande/dev";
      windl = "cd /mnt/c/Users/pande/Downloads";
      j = "z";

      # Clipboard operations
      cs = "xclip -selection clipboard";
      cso = "xclip -selection clipboard -o";
      clonec = "xclip -selection clipboard -o | xargs git clone --depth 1";
      wgetc = "xclip -selection clipboard -o | xargs wget -c ";

      # Git operations
      commit = "cz commit";
      add = "git add";
      psuh = "git push";
      push = "git push";

      # Shell commands
      ":e" = "nvim";
      e = "nvim";
      ef = "nvim (fzf)";
      ":q" = "exit";
      eixt = "exit";
      f = "fuck";
      idea = "nvim /home/shawn/dev/ideas.txt";
      neovide = "neovide.exe --wsl";
      nivm = "nvim";
      np = "nano -w PKGBUILD";
      ns = "nix-shell shell.nix --command 'nu'";
      nsp = "nix-shell --command 'nu' -p";
      nue = "nvim ~/dotnix/config/nushell/config.nu ;";
      pwsh = "pwsh.exe";
      py = "python3";
      wsl = "wsl.exe";

      cls = "clear";
      tls = "clear";
      cmb = "cmake --build Debug/";
      cmc = "rm -fr CMakeCache.txt CMakeFiles Debug/ compile_commands.json";
      taskkill = "taskkill.exe /F /IM";
      winget = "winget.exe";
    };
  in {
    # fish = {
    #   enable = true;
    #   shellAliases = sharedShellAliases;
    #   environmentVariables = envs;
    # };

    nushell = {
      enable = true;
      shellAliases = sharedShellAliases;
      environmentVariables = envs;
      configFile.source = ../../config/nushell/config.nu;
    };

    thefuck = enable_shells;
    atuin = enable_shells;
    carapace = enable_shells;
    zoxide = enable_shells;

    direnv = mergeAttrs enable_shells {
      nix-direnv.enable = true;
    };

    starship =
      mergeAttrs enable_shells
      {
        settings = {
          add_newline = true;
          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
          };
        };
      };
  };
}
