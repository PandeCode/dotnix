inputs:
with inputs; {
  nixpkgs.overlays = [
    # nix-matlab.overlay

    (final: prev: {
      # ghostty = ghostty.packages.${prev.system}.default;

      alacritty = prev.alacritty.overrideAttrs (_old: rec {
        # TODO this is rust so move to nixbuilds and cache so i dont blow up my laptop
        src = prev.fetchFromGitHub {
          owner = "GregTheMadMonk";
          repo = "alacritty-smooth-cursor";
          rev = "6d1c260460487bfa68d00f9a8e72963a51500102";
          hash = "sha256-/Tu5IIE+5sPCYYwXldq0+Keb2WcH3r5KnyjpuxwhZSM=";
        };
        cargoDeps = final.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-pbDuSvlTEUdf23LFXxK17UsXUzTUQsnnypoduUdsm+c=";
        };
      });

      # INFO this was originally a blur pr, keeping this here cuz this is how you override a buildRustPackage
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
