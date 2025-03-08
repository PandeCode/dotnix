{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nix.nix
    ./neovim.nix
    ./networking.nix
    ./services.nix
    ./packages.nix
    ./security.nix
  ];

  environment.sessionVariables = {
    NIX_BUILD_CORES = 6;
  };

  services = {
    isLaptop = true;
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
