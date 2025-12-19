# this is for caching purposes
self: let
  inherit (self) inputs;
  inherit (inputs) nixpkgs;
in
  system: let
    pkgs = nixpkgs.legacyPackages.${system};
  in rec {
    default = cachix;
    cachix = pkgs.buildEnv {
      name = "cachix";
      paths = with inputs; (
        [
          niri.packages.${system}.niri-unstable
        ]
        ++ (builtins.attrValues ((import ../derivations/default.nix) pkgs.callPackage))
        ++ (map (
            v:
              v.packages.${system}.default
          ) [
            # charon-shell
            # obolc
            nix-alien
            hermes
            boomer
            ghostty
            # inputs.zen-browser.packages."${system}".twilight
          ])
      );
    };
  }
