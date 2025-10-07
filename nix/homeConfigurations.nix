self:
with self;
with inputs; let
  mkHome = system: hostname: username:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};

      extraSpecialArgs = {
        inherit inputs outputs system hostname username dotutils;
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
        ../homes/${hostname}/home.nix
      ];
    };
  mkHomeLinux64 = mkHome systems.x86_64-linux;
  mkHomesLinux64 = names: nixpkgs.lib.genAttrs names (name: let idx = builtins.elemAt (builtins.split "@" name); in mkHomeLinux64 (idx 2) (idx 0));
in
  mkHomesLinux64 ["shawn@kazuha"]
