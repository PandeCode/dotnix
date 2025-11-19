{
  sharedConfig,
  pkgs,
  ...
}: {
  xdg.configFile = {
    "cava/shell".text = builtins.readFile ../../config/cava/shell;
  };

  programs = let
    enable_shells = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    sharedShellAliases =
      sharedConfig.shellAliases
      // (
        if sharedConfig.isWSL
        then {
          pwsh = "pwsh.exe";
          wsl = "wsl.exe";
          neovide = "neovide.exe --wsl";
          taskkill = "taskkill.exe /F /IM";
          winget = "winget.exe";
        }
        else {}
      );
  in rec {
    fish = {
      enable = true;
      shellAliases = sharedShellAliases;
    };
    bash = fish;
    nushell = fish;

    cava.enable = true;
    atuin = enable_shells;
    carapace = enable_shells;
    starship = enable_shells;

    btop = {
      enable = true;
      settings = {
        proc_tree = true;
        truecolor = true;
        proc_sorting = "memory";
        proc_aggregate = true;
      };
    };
  };
}
