{
  config,
  lib,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
  p = config.dotnix.profiles.theme.palette;
in

{
  options.dotnix.profiles.theme = {
    enable = lib.options.mkEnableOption "my stylix theme";

    palette = lib.options.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        # grays share the ground's hue, each solved for its contrast on bg
        bg = "#101215";
        surface = "#1b1e21"; # 1.12:1
        raised = "#272a2e"; # 1.3:1, selections
        border = "#3a3d41"; # 1.7:1
        dim = "#5d6165"; # 3:1, inactive borders, line numbers
        muted = "#888c90"; # 5.5:1, comments and labels
        text = "#d4d7dc"; # 13:1
        soft = "#e3e6ec"; # 15:1
        bright = "#f1f4fa"; # 17:1

        # only for things you can act on
        accent = "#61afef";

        # catppuccin mocha
        ok = "#a6e3a1";
        warn = "#f9e2af";
        error = "#f38ba8";
        info = "#74c7ec";
        keyword = "#cba6f7";
        func = "#89b4fa";
        type = "#f9e2af";
        number = "#fab387";
        string = "#a6e3a1";
        property = "#b4befe";
        operator = "#89dceb";
        embedded = "#f2cdcd";
      };
      description = ''
        The colors everything is themed from, by role. Stylix gets them as
        base16, and the hand-themed programs and web apps read the roles.
      '';
    };

    webFont = lib.options.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "The font file the web apps load, for devices without the font.";
    };

    webMonoFont = lib.options.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "The code font file the web apps load, for devices without it.";
    };
  };

  config = lib.modules.mkIf config.dotnix.profiles.theme.enable {
    stylix = {
      enable = true;

      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dharmx/walls/refs/heads/main/architecture/a_bridge_with_lights_on_it.jpg";
        sha256 = "465390cba5d4fa1861f2948b59fabe399bd2d7d53ddd6c896b0739bee4eca2c8";
      };

      # base16 for the programs stylix themes. apps use 03 for borders and
      # scrollbars as often as for comments, so it stays dim and 04 is the
      # readable gray
      base16Scheme = {
        system = "base16";
        name = "dotnix";
        author = "dotnix";
        variant = "dark";
        palette = {
          base00 = p.bg;
          base01 = p.surface;
          base02 = p.raised;
          base03 = p.dim;
          base04 = p.muted;
          base05 = p.text;
          base06 = p.soft;
          base07 = p.bright;
          base08 = p.error;
          base09 = p.number;
          base0A = p.type;
          base0B = p.string;
          base0C = p.operator;
          base0D = p.func;
          base0E = p.keyword;
          base0F = p.embedded;
        };
      };

      # dyslexic for reading, fantasque for code
      fonts = rec {
        monospace = {
          package = pkgs.nerd-fonts.fantasque-sans-mono;
          name = "FantasqueSansM Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.open-dyslexic;
          name = "OpenDyslexicM Nerd Font Mono";
        };
        serif = sansSerif;

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };

      targets = {
        # the foundry boot menu and the blahaj splash stay
        grub.enable = false;
        plymouth.enable = false;
      };
    };

    dotnix.profiles.theme = {
      webFont = lib.modules.mkDefault "${config.stylix.fonts.sansSerif.package}/share/fonts/opentype/NerdFonts/OpenDyslexic/OpenDyslexicMNerdFontMono-Regular.otf";
      webMonoFont = lib.modules.mkDefault "${config.stylix.fonts.monospace.package}/share/fonts/truetype/NerdFonts/FantasqueSansM/FantasqueSansMNerdFontMono-Regular.ttf";
    };

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
