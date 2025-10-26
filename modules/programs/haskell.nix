{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.haskell;
in {
  options.haskell.enable = lib.mkEnableOption "enable haskell";

  config = lib.mkIf cfg.enable {
    programs.neovim.extraPackages = [
      pkgs.haskell-language-server
    ];
    home.packages = with pkgs; [
      cabal-install
      ghc
      stack
    ];
  };
}
