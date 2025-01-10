{
  lib,
  config,
  ...
}: {
  imports = [
    ../../modules/programs/shells.nix
    ../../modules/programs/zellij.nix
    ../../modules/programs/bin.nix

    ../../modules/programs/neovim.nix
    ../../modules/programs/mpls.nix
    ../../modules/programs/codelldb.nix
    ../../modules/programs/cpptools.nix

    ../../modules/programs/git.nix
  ];
  disabledModules = [
  ];

  bin.enable = true;
  git.enable = true;

  neovim.enable = lib.mkDefault true;

  mpls.enable = lib.mkIf config.neovim.enable true;
  cpptools.enable = false; # lib.mkIf config.neovim.enable true;
  codelldb.enable = lib.mkIf config.neovim.enable true;

  shells.enable = lib.mkDefault true;
  zellij.enable = lib.mkDefault true;
}
