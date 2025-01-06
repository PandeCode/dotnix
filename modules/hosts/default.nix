{pkgs, ...}: {
  imports = [
    ./nix.nix
    ./neovim.nix
    ./services.nix
  ];

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };
}
