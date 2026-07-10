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
      "https://charon.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "charon.cachix.org-1:epdetEs1ll8oi8DT8OG2jEA4whj3FDbqgPFvapEPbY8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # self.submodules = true;

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixutils.url = "github:PandeCode/nixutils";
    nixbuilds = {
      url = "github:PandeCode/nixbuilds";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dwarffs = {
      url = "github:PandeCode/dwarffs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    libys = {
      url = "github:pandecode/libys";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    boomer.url = "github:nilp0inter/boomer";
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

        inherit (inputs) nixutils;
        inherit (inputs) nixbuilds;
      };

    nixosConfigurations = (import ./nix/nixosConfigurations.nix) extras;
    homeConfigurations = (import ./nix/homeConfigurations.nix) extras;
  in {
    nixosConfigurations = nixosConfigurations [];
    homeConfigurations = homeConfigurations [];

    lib = {
      appendNixos = nixosConfigurations;
      appendHome = homeConfigurations;
    };

    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    checks = extras.forAllSystems ((import ./nix/checks.nix) extras);
    devShells = extras.forAllSystems ((import ./nix/devShells.nix) extras);

    formatter = extras.forAllSystems ((
        self: system: let
          pkgs = nixpkgs.legacyPackages.${system};
          config = self.checks.${system}.pre-commit-check.config;
          inherit (config) package configFile;
          script = ''
            ${pkgs.lib.getExe package} run --all-files --config ${configFile}
          '';
        in
          pkgs.writeShellScriptBin "pre-commit-run" script
      )
      extras);

    # darwinConfigurations = {
    #   herta = darwin.lib.darwinSystem {/
    #     system = "aarch64-darwin";

    #     modules = [stylix.darwinModules.stylix ./configuration.nix];
    #   };
    # };
  };
}
