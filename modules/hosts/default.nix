{pkgs, ...}: {
  imports = [
    ./nix.nix
    ./neovim.nix
    ./services.nix
  ];

  services = {
    enable = true;
    isLaptop = false;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };
}
