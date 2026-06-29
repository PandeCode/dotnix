self: let
  inherit (self.inputs) nixpkgs;
in
  system: {
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
  }
