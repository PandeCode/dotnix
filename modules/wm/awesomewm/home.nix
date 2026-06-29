{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.awesomewm;
in {
  imports = [../x/home.nix];

  options.awesomewm.enable = lib.mkEnableOption "enable awesomewm";

  config = lib.mkIf cfg.enable {
    x.enable = true;
    xdg.configFile."awesome/rc.lua".text = builtins.readFile ../../../config/awesome/rc.lua;
  };
}
