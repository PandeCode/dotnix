{
  config,
  lib,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
in

{
  options.dotnix.profiles.theme = {
    enable = lib.options.mkEnableOption "my stylix theme";

    webFont = lib.options.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "The font file the web apps load, for devices without the font.";
    };
  };

  config = lib.modules.mkIf config.dotnix.profiles.theme.enable {
    stylix = {
      enable = true;

      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/architecture/a_bridge_with_lights_on_it.jpg";
        sha256 = "465390cba5d4fa1861f2948b59fabe399bd2d7d53ddd6c896b0739bee4eca2c8";
      };

      # onedark-dark from tinted-theming/schemes, inline so evaluation does
      # not have to build base16-schemes to read it
      base16Scheme = {
        system = "base16";
        name = "OneDark Dark";
        author = "olimorris (https://github.com/olimorris)";
        variant = "dark";
        palette = {
          base00 = "#000000";
          base01 = "#1c1f24";
          base02 = "#2c313a";
          base03 = "#434852";
          base04 = "#565c64";
          base05 = "#abb2bf";
          base06 = "#b6bdca";
          base07 = "#c8ccd4";
          base08 = "#ef596f";
          base09 = "#d19a66";
          base0A = "#e5c07b";
          base0B = "#89ca78";
          base0C = "#2bbac5";
          base0D = "#61afef";
          base0E = "#d55fde";
          base0F = "#be5046";
        };
      };

      fonts = rec {
        monospace = {
          package = pkgs.nerd-fonts.open-dyslexic;
          name = "OpenDyslexicM Nerd Font Mono";
        };
        serif = monospace;
        sansSerif = monospace;

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };

      targets = {
        # the hyperfluent theme and the blahaj splash stay
        grub.enable = false;
        plymouth.enable = false;
      };
    };

    dotnix.profiles.theme.webFont = lib.modules.mkDefault "${config.stylix.fonts.monospace.package}/share/fonts/opentype/NerdFonts/OpenDyslexic/OpenDyslexicMNerdFontMono-Regular.otf";

    # for scripts that want the colors
    environment.sessionVariables = {
      STYLIX_FONT = config.stylix.fonts.sansSerif.name;

      STYLIX_BLACK = c.base00;
      STYLIX_WHITE = c.base07;
      STYLIX_RED = c.base08;
      STYLIX_GREEN = c.base0B;
      STYLIX_BLUE = c.base0D;
      STYLIX_YELLOW = c.base0A;

      STYLIX_BASE00 = c.base00;
      STYLIX_BASE01 = c.base01;
      STYLIX_BASE02 = c.base02;
      STYLIX_BASE03 = c.base03;
      STYLIX_BASE04 = c.base04;
      STYLIX_BASE05 = c.base05;
      STYLIX_BASE06 = c.base06;
      STYLIX_BASE07 = c.base07;
      STYLIX_BASE08 = c.base08;
      STYLIX_BASE09 = c.base09;
      STYLIX_BASE0A = c.base0A;
      STYLIX_BASE0B = c.base0B;
      STYLIX_BASE0C = c.base0C;
      STYLIX_BASE0D = c.base0D;
      STYLIX_BASE0E = c.base0E;
      STYLIX_BASE0F = c.base0F;
    };
  };
}
