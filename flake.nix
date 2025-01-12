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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    # darwin = {
    #   url = "github:LnL7/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # pyproject-nix = {
    #   url = "github:pyproject-nix/pyproject.nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    #
    # uv2nix = {
    #   url = "github:pyproject-nix/uv2nix";
    #   inputs.pyproject-nix.follows = "pyproject-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    #
    # pyproject-build-systems = {
    #   url = "github:pyproject-nix/build-system-pkgs";
    #   inputs.pyproject-nix.follows = "pyproject-nix";
    #   inputs.uv2nix.follows = "uv2nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    nixos-wsl,
    stylix,
    # uv2nix,
    # pyproject-nix,
    # pyproject-build-systems,
    ...
  } @ inputs: let
    inherit (self) outputs;
    inherit (inputs.nixpkgs.lib) attrValues;

    system = "x86_64-linux";

    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    overlays = {
      nixpkgs.overlays = with inputs; [
        neovim-nightly-overlay.overlays.default
      ];
    };
  in {
    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    nixosConfigurations = {
      nixiso = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs;
          inherit nixpkgs-stable;
        };
        modules = [
          overlays
          stylix.nixosModules.stylix
          ./hosts/nixiso/configuration.nix
        ];
      };

      wslnix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit nixpkgs-stable;
          inherit inputs;
        };
        modules = [
          nixos-wsl.nixosModules.default
          overlays

          stylix.nixosModules.stylix
          ./hosts/wslnix/configuration.nix
        ];
      };

      # darwinConfigurations."«hostname»" = darwin.lib.darwinSystem {
      #   system = "aarch64-darwin";
      #   modules = [stylix.darwinModules.stylix ./configuration.nix];
      # };
    };

    homeConfigurations = let
      username = "shawn";
      os = "wslnix";
    in {
      "${username}@${os}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        extraSpecialArgs = {inherit inputs outputs;};

        modules = [
          overlays
          stylix.homeManagerModules.stylix
          {
            home = rec {
              inherit username;
              homeDirectory = "/home/${username}";
              stateVersion = "24.05";
            };
          }
          ./homes/${os}/home.nix
        ];
      };
    };

    checks = forAllSystems (system: {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          check-added-large-files.enable = true;
          ripsecrets.enable = true;
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
