inputs:
with inputs; {
  nixpkgs.overlays = [
    nix-matlab.overlay
    (_final: prev: {
      ghostty = ghostty.packages.${prev.system}.default;

      # niri-unstable = prev.niri-unstable.overrideAttrs (_old: rec {
      #   src = prev.fetchFromGitHub {
      #     owner = "niri-wm";
      #     repo = "niri";
      #     rev = "refs/pull/3483/head";
      #     hash = "sha256-ZiGGjRL2H67GcL6BvZV99khW++aHpJ2NA4n71qZiJ9A=";
      #   };
      #   cargoDeps = final.rustPlatform.fetchCargoVendor {
      #     inherit src;
      #     hash = "sha256-Fv3uClwuuAAGTQ7ujuAQW7xCoYFCw4q9QC08Z7Q7Hdk=";
      #   };
      # });
    })
  ];
}
