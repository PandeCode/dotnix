{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}: let
  win_user = "pande";
in {
  imports = [
    ../../modules/programs/default.nix
    ../../modules/homes/stylix.nix
  ];

  spicetify.enable = true;

  stylix_home = {
    enable = true;
    dis.enable = true;
  };

  home = {
    inherit (osConfig.system) stateVersion;
  };
}
