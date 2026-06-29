{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.xmonad;
in {
  imports = [../x/os.nix];
  options.xmonad.enable = lib.mkEnableOption "enable xmonad";

  config = lib.mkIf cfg.enable {
    x.enable = true;

    services.xserver.windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      ghcArgs = [
        "-hidir /tmp" # place interface files in /tmp, otherwise ghc tries to write them to the nix store
        "-odir /tmp" # place object files in /tmp, otherwise ghc tries to write them to the nix store
        "-i${inputs.xmonad-contexts}" # tell ghc to search in the respective nix store path for the module
      ];
      extraPackages = haskellPackages: [
        haskellPackages.dbus
        haskellPackages.List
        haskellPackages.monad-logger
      ];
      config = builtins.readFile ../../../config/xmonad/xmonad.hs;
    };
  };
}
