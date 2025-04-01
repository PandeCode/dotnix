{
pkgs,
sharedConfig,
...
}: let
    homeDir = "/home/${sharedConfig.userName}";
    wallpaperPath = "${homeDir}/Pictures/walls";

    # Check for existence of common image formats
    hasMainPng = builtins.pathExists "${wallpaperPath}/main.png";
    hasMainJpg = builtins.pathExists "${wallpaperPath}/main.jpg";
    hasMainJpeg = builtins.pathExists "${wallpaperPath}/main.jpeg";
    hasMainWebp = builtins.pathExists "${wallpaperPath}/main.webp";

    # If any image exists, use it, otherwise fetch from GitHub
    image =
        if (hasMainPng || hasMainJpg || hasMainJpeg || hasMainWebp)
            then "${wallpaperPath}/main.${
            if hasMainPng
                then "png"
            else if hasMainJpg
                then "jpg"
            else if hasMainJpeg
                then "jpeg"
            else "webp"
        }"
        else
            pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/architecture/a_bridge_with_lights_on_it.jpg";
                sha256 = "465390cba5d4fa1861f2948b59fabe399bd2d7d53ddd6c896b0739bee4eca2c8";
            };
in {
    stylix = {
        enable = true;

        inherit image;

        base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";


   cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Mordern-Ice";
            size = 12;
    };

        # polarity = "dark";

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
