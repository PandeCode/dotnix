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
      url = "github:nix-community/home-manager?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pyproject-nix = {
    #   url = "github:pyproject-nix/pyproject.nix?shallow=1";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    #
    # uv2nix = {
    #   url = "github:pyproject-nix/uv2nix?shallow=1";
    #   inputs.pyproject-nix.follows = "pyproject-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    #
    # pyproject-build-systems = {
    #   url = "github:pyproject-nix/build-system-pkgs?shallow=1";
    #   inputs.pyproject-nix.follows = "pyproject-nix";
    #   inputs.uv2nix.follows = "uv2nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay?shallow=1";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix?shallow=1";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    nixos-wsl,
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
          ./hosts/iso/configuration.nix
        ];
      };

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
          overlays
          {
            home = {
              username = "shawn";
              homeDirectory = "/home/shawn";
              stateVersion = "24.05";
            };
          }
          ./homes/wslnix/home.nix
          ./modules/desktop_env/hyprland.nix
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
