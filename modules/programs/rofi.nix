{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.rofi;
in {
  options.rofi.enable = lib.mkEnableOption "enable rofi";

  config = lib.mkIf cfg.enable {
    programs = {
      rofi = with pkgs; {
        enable = true;
        package = rofi-wayland;
        plugins = [rofi-emoji];
        cycle = true;
        terminal = "kitty";
        theme = lib.mkForce (let
          # Use `mkLiteral` for string-like values that should show without
          # quotes, e.g.:
          # {
          #   foo = "abc"; => foo: "abc";
          #   bar = mkLiteral "abc"; => bar: abc;
          # };
          inherit (config.lib.formats.rasi) mkLiteral;
          l = mkLiteral;
          font = config.stylix.fonts.sansSerif.name;
          c = config.lib.stylix.colors;
          bg0 = l "#${c.base00}E6";
          bg1 = l "#${c.base01}80";
          bg2 = l "#${c.base02}E6";
          fg0 = l "#${c.base04}";
          fg1 = l "#${c.base05}";
          fg2 = l "#${c.base06}80";
        in rec {
          /*
          MACOS SPOTLIGHT LIKE DARK THEME FOR ROFI
          Author: Newman Sanchez (https://github.com/newmanls)
          */
          "*" = {
            font = "${font} 12";
            background-color = l "transparent";
            text-color = fg0;
            margin = 0;
            padding = 0;
            spacing = 0;
          };

          window = {
            background-color = bg0;

            location = l "center";
            width = 640;
            border-radius = 8;
          };

          inputbar = {
            font = "${font} 20";
            padding = l "12px";
            spacing = l "12px";
            children = map l ["icon-search" "entry"];
          };

          icon-search = {
            expand = false;
            filename = "search";
            size = l "28px";
          };

          "icon-search, entry, element-text, element-icon" = {
            vertical-align = l "0.5";
          };

          entry = {
            font = l "inherit";
            placeholder = "Search";
            placeholder-color = fg2;
          };

          element-icon = {
            size = l "1em";
          };

          element-text = {
            text-color = l "inherit";
          };

          message = {
            border = l "2px 0 0";
            border-color = bg1;
            background-color = bg1;
          };

          textbox = {
            padding = l "8px 24px";
          };

          listview = {
            lines = 10;
            columns = 1;

            fixed-height = false;
            border = l "1px 0 0";
            border-color = bg1;
          };

          element = {
            padding = l "8px 16px";
            spacing = l "16px";
            background-color = l "transparent";
          };

          "element normal active" = {
            text-color = bg2;
          };

          "element alternate active" = {
            text-color = bg2;
          };

          "element selected normal, element selected active" = {
            background-color = bg2;
            text-color = fg1;
          };
        });
      };

      rbw = {
        enable = true;
        settings.email = config.programs.git.userEmail;
        package = pkgs.rofi-rbw-wayland;
      };
    };
  };
}
