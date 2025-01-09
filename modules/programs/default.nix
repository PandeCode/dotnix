{
  lib,
  config,
  ...
}: {
  imports = [
    ../../modules/programs/bin.nix
    ../../modules/programs/codelldb.nix
    ../../modules/programs/git.nix
    ../../modules/programs/mpls.nix
    ../../modules/programs/neovim.nix
    ../../modules/programs/shells.nix
    ../../modules/programs/zellij.nix
  ];
  disabledModules = [
  ];

  bin.enable = true;
  git.enable = true;

  neovim.enable = lib.mkDefault true;

  mpls.enable = lib.mkIf config.neovim.enable true;
  codelldb.enable = lib.mkIf config.neovim.enable true;

  shells.enable = lib.mkDefault true;
  zellij.enable = lib.mkDefault true;
}
