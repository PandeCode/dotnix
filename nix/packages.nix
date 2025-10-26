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
          # hyprland.packages.${system}.hyprland;
        ]
        ++ (map (
            v:
              v.packages.${system}.default
          ) [
            # charon-shell
            # obolc
            hermes
            ghostty
            zjstatus
            # inputs.zen-browser.packages."${system}".twilight
          ])
      );
    };
  }
