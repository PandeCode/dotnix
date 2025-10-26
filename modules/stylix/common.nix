{pkgs, ...}: let
  image = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/architecture/a_bridge_with_lights_on_it.jpg";
    sha256 = "465390cba5d4fa1861f2948b59fabe399bd2d7d53ddd6c896b0739bee4eca2c8";
  };
in {
  stylix = {
    inherit image;

    enable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Mordern-Ice";
      size = 12;
    };

    fonts = rec {
      monospace = {
        package = pkgs.nerd-fonts.fantasque-sans-mono;
        name = "FantasqueSansM Nerd Font Mono";
      };

      serif = monospace;
      sansSerif = monospace;

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "noto color emoji";
      };
    };
  };
}
