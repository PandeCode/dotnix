{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.awesomewm;
in {
  imports = [../x/os.nix];
  options.awesomewm.enable = lib.mkEnableOption "enable awesomewm";

  config = lib.mkIf cfg.enable {
    x.enable = true;

    services.xserver.windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks # is the package manager for Lua modules
        luadbi-mysql # Database abstraction layer
      ];
    };
  };
}
