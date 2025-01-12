{pkgs, ...}: {
  stylix = {
    enable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/architecture/a_bridge_with_lights_on_it.jpg";
      sha256 = "465390cba5d4fa1861f2948b59fabe399bd2d7d53ddd6c896b0739bee4eca2c8";
    };
    # polarity = "dark";

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "dejavu serif";
      };

      # sansserif = {
      #   package = pkgs.dejavu_fonts;
      #   name = "dejavu sans";
      # };

      monospace = {
        package = pkgs.dejavu_fonts;
        name = "dejavu sans mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "noto color emoji";
      };
    };
  };
}
