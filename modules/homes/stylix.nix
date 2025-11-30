{
  pkgs,
  lib,
  config,
  ...
} @ all: {
  home = {
    file.".newsboat/config".text = with config.lib.stylix.colors.withHashtag; ''
      color background ${base00}
      color foreground ${base05}
      color listnormal ${base05}
      color listfocus ${base0B} default bold
      color article ${base05}
      color error ${base08} default bold
      color progress ${base0D}
      color guide ${base0A}
      color info ${base03}
      color url ${base0E} underline
      color time ${base04}
      color unread ${base0C} default bold

      highlight -r "^(Breaking|BREAKING)" ${base08} default bold
      highlight "https?://[^\s]+" ${base0E} underline
      color search ${base0A}

      ${builtins.readFile ../../config/newsboat/config}
    '';
  };

  xdg.configFile = with config.lib.stylix.colors.withHashtag; {
    "gowall/config.yml".text =
      lib.strings.toJSON
      {
        EnableImagePreviewing = false;
        themes = [
          {
            name = "nix";
            colors = [base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F];
          }
        ];
      };

    "stylix/font".text = config.stylix.fonts.sansSerif.name;

    "stylix/style.sh".text =
      /*
      sh
      */
      ''
        export base00=${base00}
        export base01=${base01}
        export base02=${base02}
        export base03=${base03}
        export base04=${base04}
        export base05=${base05}
        export base06=${base06}
        export base07=${base07}
        export base08=${base08}
        export base09=${base09}
        export base0A=${base0A}
        export base0B=${base0B}
        export base0C=${base0C}
        export base0D=${base0D}
        export base0E=${base0E}
        export base0F=${base0F}
      '';

    "stylix/style.scss".text =
      /*
      scss
      */
      ''
        $base00: ${base00}; $base01: ${base01}; $base02: ${base02}; $base03: ${base03};
        $base04: ${base04}; $base05: ${base05}; $base06: ${base06}; $base07: ${base07};
        $base08: ${base08}; $base09: ${base09}; $base0A: ${base0A}; $base0B: ${base0B};
        $base0C: ${base0C}; $base0D: ${base0D}; $base0E: ${base0E}; $base0F: ${base0F};
      '';
    "stylix/style.lua".text =
      /*
      lua
      */
      ''
        return {
          base00 = '${base00}', base01 = '${base01}', base02 = '${base02}', base03 = '${base03}',
          base04 = '${base04}', base05 = '${base05}', base06 = '${base06}', base07 = '${base07}',
          base08 = '${base08}', base09 = '${base09}', base0A = '${base0A}', base0B = '${base0B}',
          base0C = '${base0C}', base0D = '${base0D}', base0E = '${base0E}', base0F = '${base0F}'
        }
      '';
  };

  specialisation = let
    mkconfig = THEME: {
      sessionVariables.THEME = THEME;
      activation.setTheme =
        lib.mkForce
        (lib.hm.dag.entryAfter ["writeBoundary"] ''
          ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-${THEME}"
        '');
    };
  in {
    dark.configuration = {
      stylix.base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
      home = mkconfig "dark";
    };

    light.configuration = {
      stylix.base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/tokyo-night-light.yaml";
      home = mkconfig "light";
    };
  };

  home = {
    sessionVariables = {
      XCURSOR_THEME = config.stylix.cursor.name;
      XCURSOR_SIZE = config.stylix.cursor.size;
    };
    activation.setTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    '';
  };

  stylix =
    (import ../stylix/common.nix all).stylix
    // {
      iconTheme = {
        enable = true;
        package = pkgs.arc-icon-theme;
        dark = "Arc-Dark";
        light = "Arc";
      };

      targets = let
        f = lib.mkForce false;
      in {
        rofi.enable = f;
        hyprpaper.enable = f;
        hyprland.hyprpaper.enable = f;
        neovim.enable = f;
        waybar.enable = f;
        hyprlock.enable = f;
      };
    };
}
