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
      "https://hyprland.cachix.org"
      "https://charon.cachix.org"
      # "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "charon.cachix.org-1:epdetEs1ll8oi8DT8OG2jEA4whj3FDbqgPFvapEPbY8="
      # "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  inputs = {
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

    # niri.url = "github:sodiboo/niri-flake";

    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };

    dwm-flexipatch = {
      url = "github:pandecode/dwm-flexipatch";
      flake = false;
    };

    # xmonad-contexts = {
    #   url = "github:Procrat/xmonad-contexts";
    #   flake = false;
    # };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    iwmenu = {
      url = "github:e-tho/iwmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zjstatus = {
      url = "github:dj95/zjstatus";
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

    # obol = {
    #   url = "github:PandeCode/obol";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    obolc = {
      url = "github:PandeCode/obolc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;

    systems = {
      x86_64-linux = "x86_64-linux";
      # aarch64-linux = "aarch64-linux";
      # x86_64-darwin = "x86_64-darwin";
      # aarch64-darwin = "aarch64-darwin";
    };

    supportedSystems = builtins.attrNames systems;
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    overlays = {
      nixpkgs.overlays = with inputs; [
        (final: prev: {
          zjstatus = zjstatus.packages.${prev.system}.default;
        })
      ];
    };

    # created to emulate osConfig with home_manager and to share config between nixos and home-manager
    sharedConfig_kazuha = {
      hostName = "kazuha";
      hostname = "kazuha";

      userName = "shawn";
      username = "shawn";
      user = "shawn";

      terminal = "kitty";
      explorer = "nautilus";

      gaming = {
        enable = true;
        epic = true;
        minecraft = true;
        osu = false;
        ps2 = false;
        switch = false;
        wallpaperengine = false;
        wii = false;
      };

      virt_manager.enable = false;
      osx-kvm.enable = false;

      wms = {
        hyprland.enable = true;
        sway.enable = true;
        i3.enable = true;
        dwm.enable = true;
        river.enable = false;
        niri.enable = false; # issue https://github.com/sodiboo/niri-flake/issues/1018
        # dwm.enable = true;
        # xmonad.enable = true;
        # bspwm.enable = true;
        # awesomewm.enable = true;
      };
    };

    stateVersion = "24.11";
    /*
    WARN: Do not change,
     Everything BREAKS,
     So much PTSD, headache and tears. Almost made me quit nix, not related to `nix --version`
    */

    dotutils = import ./utils/default.nix nixpkgs;
  in {
    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    nixosConfigurations = let
      mkSystem = system: sys_name: extra_modules: args:
        nixpkgs.lib.nixosSystem {
          specialArgs =
            {
              inherit inputs outputs system sys_name dotutils nixConfig;
              pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${system};
            }
            // args;
          modules =
            [
              {nix.settings = nixConfig;}
              overlays
              inputs.stylix.nixosModules.stylix
              ./hosts/${sys_name}/configuration.nix
            ]
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
        ] {sharedConfig = sharedConfig_kazuha;};
      # jinwoo = mkSystemLinux64 "jinwoo " [];
    };

    # darwinConfigurations = {
    #   herta = darwin.lib.darwinSystem {/
    #     system = "aarch64-darwin";

    #     modules = [stylix.darwinModules.stylix ./configuration.nix];
    #   };
    # };

    homeConfigurations = let
      mkHome = system: sys_name: username:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};

          extraSpecialArgs = {
            inherit inputs outputs system sys_name username dotutils;
            sharedConfig = sharedConfig_kazuha;
            pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${system};
          };

          modules = [
            overlays
            inputs.stylix.homeModules.stylix
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
      mkHomesLinux64 = names: nixpkgs.lib.genAttrs names (name: let idx = builtins.elemAt (builtins.split "@" name); in mkHomeLinux64 (idx 2) (idx 0));
    in
      mkHomesLinux64 ["shawn@kazuha"];
    # {
    #   # "shawn@wslnix" = mkHomeLinux64 "wslnix" "shawn";
    #   "shawn@kazuha" = mkHomeLinux64 "kazuha" "shawn";
    #   # "shawn@jinwoo" = mkHomeLinux64 "jinwoo" "shawn"; # TODO: New system
    #   # "shawn@herta" = mkHomeDarwin "herta" "shawn"; # TODO: New system
    # }j

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
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          nh
          alejandra
          statix
          deadnix
          nixd
          nix-init
          nix-index
          nix-fast-build

          # ghc
        ];
      };

      pre-commit = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    });
  };
}
