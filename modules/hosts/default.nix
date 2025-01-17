{pkgs, ...}: {
  imports = [
    ./nix.nix
    ./neovim.nix
    ./boot.nix
    ./services.nix
    ./packages.nix
  ];

  packages.enable = true;

  environment.sessionVariables = {
    NIX_BUILD_CORES = 6;
  };

  boot_opts.enable = true;

  services = {
    enable = true;
    isLaptop = false;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };
}
