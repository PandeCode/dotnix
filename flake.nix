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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay?shallow=1";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
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

    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  in {
    nixosConfigurations = {
      wslnix = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {inherit nixpkgs-stable;};

        modules = [
          nixos-wsl.nixosModules.default
          {
            nixpkgs.overlays = overlays;
          }
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

    checks = forAllSystems (system: {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          # "taplo fmt".enable = true; # toml
          alejandra.enable = true;
          check-added-large-files.enable = true;
          check-json.enable = true;
          check-shebang-scripts-are-executable.enable = true;
          check-symlinks.enable = true;
          check-toml.enable = true;
          check-yaml.enable = true;
          end-of-file-fixer.enable = true;
          mixed-line-endings.enable = true;
          prettier.enable = true;
          shellcheck.enable = true;
          shfmt.enable = true;
          statix.enable = true;
          trim-trailing-whitespace.enable = true;
        };
      };
    });

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    });
  };
}
