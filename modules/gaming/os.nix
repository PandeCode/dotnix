{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.gaming_os;
in {
  programs = {
    steam.enable = true;
    gamemode.enable = true;
  };
}
