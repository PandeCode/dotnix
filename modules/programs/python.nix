{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.python;
in {
  options.python.enable = lib.mkEnableOption "enable python";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (pkgs.python3.withPackages (python-pkgs:
        with python-pkgs; [
        ]))
    ];
  };
}
