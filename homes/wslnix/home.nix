{
  config,
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

  stylix_home = {
    enable = true;
    dis.enable = false;
  };
}
