{
  config,
  pkgs,
  ...
}: {
  home.file.".config/zellji/config.kdl".source = ../../config/zellij/config.kdl;

  programs = let
    mergeAttrs = pkgs.lib.mergeAttrs;
    enable_shells = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
  in {
    zellij = {
      enable = true;
      enableBashIntegration = true;
    };

    nushell = {
      enable = true;
      shellAliases = {
        ":e" = "nvim";
        ":q" = "exit";
        mkdir = "mkdir";
        mkdri = "mkdir";
        mkidr = "mkdir";
        mdkir = "mkdir";
        dmkir = "mkdir";
        clonec = "git clone --depth 1 (xclip -selection clipboard -o)";
        cls = "clear";
        cmb = "cmake --build Debug/";
        cmc = "rm -fr CMakeCache.txt CMakeFiles Debug/ compile_commands.json";
        commit = "cz commit";
        cp = "cp -ir";
        cs = "xclip -selection clipboard";
        cso = "xclip -selection clipboard -o";
        df = "df -h";
        eixt = "exit";
        f = "fuck";
        free = "free -m";
        idea = "nvim /home/shawn/dev/ideas.txt";
        j = "z";
        l = "ls -la";
        md = "mkdir";
        more = "less";
        neovide = "neovide.exe --wsl";
        nivm = "nvim";
        np = "nano -w PKGBUILD";
        ns = "nix-shell shell.nix --command 'nu'";
        nsp = "nix-shell --command 'nu' -p";
        nue = "nvim ~/dotnix/config/nushell/config.nu ;";
        psuh = "git push";
        push = "git push";
        pwsh = "pwsh.exe";
        py = "python3";
        sizeof = "du -h --max-depth=0";
        sl = "ls";
        taskkill = "taskkill.exe /F /IM";
        tls = "clear";
        tree = "tre";
        wgetc = "wget -c (xclip -selection clipboard -o)";
        win = "cd /mnt/c/Users/pande";
        windev = "cd /mnt/c/Users/pande/dev";
        windl = "cd /mnt/c/Users/pande/Downloads";
        winget = "winget.exe";
        wsl = "wsl.exe";
      };
      # environmentVariables = {};
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
