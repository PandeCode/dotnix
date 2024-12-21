{
  description = "nix config";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
      "https://aseipp-nix-cache.global.ssl.fastly.net"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable?shallow=1";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11?shallow=1";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main?shallow=1";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay?shallow=1";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    nixos-wsl,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      wslnix = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {inherit nixpkgs-stable;};

        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05"; # IMPORTANT: NixOS-WSL breaks on other state versions
            networking.hostName = "wslnix";
            wsl = {
              enable = true;
              defaultUser = "shawn";
              wslConf.network.hostname = "wslnix";
            };
          }
          ./hosts/wslnix/configuration.nix
        ];
      };
    };

    homeConfigurations = {
      "shawn@wslnix" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        extraSpecialArgs = {inherit inputs outputs;};

        modules = [
          {
            home = {
              username = "shawn";
              homeDirectory = "/home/shawn";
              stateVersion = "24.05";
            };
          }
          ./homes/wslnix/home.nix
        ];
      };
    };
  };
}
