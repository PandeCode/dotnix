rec {
  description = "nix config";

  nixConfig = rec {
    trusted-users = ["root" "shawn"];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
      "https://aseipp-nix-cache.global.ssl.fastly.net"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-substituters = extra-substituters;
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    # nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # darwin = {
    #   url = "github:LnL7/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

    stylix.url = "github:danth/stylix";

    zen-browser.url = "github:MarceColl/zen-browser-flake";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprswitch.url = "github:h3rmt/hyprswitch/release";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };

    xmonad-contexts = {
      url = "github:Procrat/xmonad-contexts";
      flake = false;
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;

    systems = {
      x86_64-linux = "x86_64-linux";
      aarch64-linux = "aarch64-linux";
      x86_64-darwin = "x86_64-darwin";
      aarch64-darwin = "aarch64-darwin";
    };

    supportedSystems = builtins.attrNames systems;
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    overlays = {nixpkgs.overlays = with inputs; [neovim-nightly-overlay.overlays.default];};

    # created to emulate osConfig with home_manager
    sharedConfig = {
      gaming.enable = false;

      hyprland.enable = true;
      sway.enable = true;
      i3.enable = true;
      dwm.enable = true;
      xmonad.enable = true;
      awesomewm.enable = true;
      bspwm.enable = true;
    };

    stateVersion = "24.11";
    /*
    WARN: Do not change,
     Everything BREAKS,
     So much PTSD, headache and tears. Almost made me quit nix, not related to `nix --version`
    */
  in {
    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    nixosConfigurations = let
      mkSystem = system: sys_name: extra_modules:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs system sys_name sharedConfig;
            pkgs-stable = nixpkgs-stable.legacyPackages.${system};
          };
          modules =
            [{nix.settings = nixConfig;} overlays inputs.stylix.nixosModules.stylix ./hosts/${sys_name}/configuration.nix]
            ++ extra_modules;
        };
      mkSystemLinux64 = mkSystem systems.x86_64-linux;
    in {
      # nixiso = mkSystemLinux64 "nixiso" [
      #   home-manager.nixosModules.home-manager
      #   inputs.spicetify-nix.nixosModules.default
      # ];
      # wslnix = mkSystemLinux64 "wslnix" [inputs.nixos-wsl.nixosModules.default];

      kazuha =
        mkSystemLinux64 "kazuha" [
        ];
      # jinwoo = mkSystemLinux64 "jinwoo " [];
    };

    # darwinConfigurations = {
    #   herta = darwin.lib.darwinSystem {
    #     system = "aarch64-darwin";
    #     modules = [stylix.darwinModules.stylix ./configuration.nix];
    #   };
    # };

    homeConfigurations = let
      mkHome = system: sys_name: username:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};

          extraSpecialArgs = {
            inherit inputs outputs system sys_name username sharedConfig;
            pkgs-stable = nixpkgs-stable.legacyPackages.${system};
          };

          modules = [
            overlays
            inputs.stylix.homeManagerModules.stylix
            {
              nix.package = nixpkgs.legacyPackages.${system}.nix;
              home = rec {
                inherit username stateVersion;
                homeDirectory = "/home/${username}";
              };
            }
            ./homes/${sys_name}/home.nix
          ];
        };
      mkHomeLinux64 = mkHome systems.x86_64-linux;
    in {
      # "shawn@wslnix" = mkHomeLinux64 "wslnix" "shawn";
      "shawn@kazuha" = mkHomeLinux64 "kazuha" "shawn";
      # "shawn@kazuha" = mkHomeLinux64 "kazuha" "shawn"; # TODO: New system
      # "shawn@jinwoo" = mkHomeLinux64 "jinwoo" "shawn"; # TODO: New system
      # "shawn@herta" = mkHomeDarwin "herta" "shawn"; # TODO: New system
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
