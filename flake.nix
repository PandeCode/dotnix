{
  description = "nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nixpkgs-stable, home-manager, nixos-wsl, ... }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {

          inherit system;

          specialArgs = { inherit nixpkgs-stable; };

          modules = [
            nixos-wsl.nixosModules.default
            {
              system.stateVersion =
                "24.05"; # IMPORTANT: NixOS-WSL breaks on other state versions
              wsl = {
                enable = true;
                defaultUser = "nixos";
              };
            }
            ./nixos/configuration.nix
          ];
        };
      };

      homeConfigurations.nixos = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        extraSpecialArgs = { inherit inputs outputs; };

        modules = [
          {
            home = {
              username = "nixos";
              homeDirectory = "/home/nixos";
              stateVersion = "24.05";
            };
          }
          ./home-manager/home.nix

        ];
      };

    };
}
