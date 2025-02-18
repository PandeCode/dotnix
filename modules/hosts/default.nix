{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nix.nix
    ./neovim.nix
    ./services.nix
    ./packages.nix
  ];

  packages.enable = true;

  environment.sessionVariables = {
    NIX_BUILD_CORES = 6;
  };

  services = {
    enable = true;
    isLaptop = false;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
    # config.allowUnfreePredicate = pkg:
    #   builtins.elem (lib.getName pkg) [
    #     "google-chrome"
    #     "spotify"
    #     "obsidian"
    #   ];
  };
}
