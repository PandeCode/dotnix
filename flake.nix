rec {
  description = "nix config";

  nixConfig = {
    trusted-users = ["root" "shawn"];
    experimental-features = ["nix-command" "flakes" "pipe-operators"];
    accept-flake-config = true;
    show-trace = true;
    auto-optimise-store = true;

    # substituters = ["https://aseipp-nix-cache.freetls.fastly.net"];

    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://charon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "charon.cachix.org-1:epdetEs1ll8oi8DT8OG2jEA4whj3FDbqgPFvapEPbY8="
    ];
  };

  inputs = {
    self.submodules = true;

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # darwin = {
    #   url = "github:LnL7/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland.url = "github:hyprwm/Hyprland";
    #
    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };
    # hypr-dynamic-cursors = {
    #   url = "github:VirtCode/hypr-dynamic-cursors";
    #   inputs.hyprland.follows = "hyprland";
    # };
    # xmonad-contexts = {
    #   url = "github:Procrat/xmonad-contexts";
    #   flake = false;
    # };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes = {
      url = "github:pandecode/hermes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    obolc = {
      url = "github:PandeCode/obolc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
    };
    stylix.url = "github:danth/stylix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs"; #
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    extras =
      self
      // rec {
        inherit nixConfig;

        systems = {
          x86_64-linux = "x86_64-linux";
          # aarch64-linux = "aarch64-linux";
          # x86_64-darwin = "x86_64-darwin";
          # aarch64-darwin = "aarch64-darwin";
        };
        supportedSystems = builtins.attrNames systems;
        forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

        stateVersion = "24.11";
        dotutils = import ./utils/default.nix nixpkgs;

        sharedConfig_kazuha = import ./osConfigs/kazuha.nix;

        overlays = (import ./nix/overlays.nix) inputs;
      };
  in {
    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    nixosConfigurations = (import ./nix/nixosConfigurations.nix) extras;
    homeConfigurations = (import ./nix/homeConfigurations.nix) extras;
    checks = extras.forAllSystems ((import ./nix/checks.nix) extras);
    devShells = extras.forAllSystems ((import ./nix/devShells.nix) extras);
    packages = extras.forAllSystems ((import ./nix/packages.nix) extras);

    # darwinConfigurations = {
    #   herta = darwin.lib.darwinSystem {/
    #     system = "aarch64-darwin";

    #     modules = [stylix.darwinModules.stylix ./configuration.nix];
    #   };
    # };
  };
}
