{
  pkgs,
  config,
  ...
}: let
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

  bg3 = l "#${c.base03}80";

  accent = l "#60cdff";
  urgent = accent;

  macos = {
    /*
    MACOS SPOTLIGHT LIKE DARK THEME FOR ROFI
    */
    /*
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
  };

  windows-11-list = {
    "*" = {
      font = "${font} 10";

      background-color = l "transparent";
      text-color = fg0;

      margin = 0;
      padding = 0;
      spacing = 0;
    };

    "element-icon, element-text, scrollbar" = {
      cursor = l "pointer";
    };

    window = {
      location = l "south";
      width = l "600px";
      height = l "600px";
      y-offset = l "-4px";

      background-color = bg1;
      border-radius = l "8px";
    };

    mainbox = {
      padding = l "24px";
      spacing = l "24px";
    };

    inputbar = {
      padding = l "8px";
      spacing = l "4px";
      children = map l ["icon-search" "entry"];
      border = l "0 0 2px 0 solid";
      border-color = accent;
      border-radius = l "2px";
      background-color = bg0;
    };

    "icon-search, entry, element-icon, element-text " = {
      vertical-align = l "0.5";
    };

    icon-search = {
      expand = false;
      filename = "search-symbolic";
      size = l "24px";
    };

    entry = {
      font = "${font} 12";
      placeholder = "Type here to search";
      placeholder-color = fg1;
    };

    textbox = {
      padding = l "4px 8px";
      background-color = bg2;
    };

    listview = {
      columns = 2;
      spacing = l "8px";
      fixed-height = true;
      fixed-columns = true;
    };

    element = {
      spacing = l " 1em";
      padding = l "8px";
      border-radius = l "2px";
    };

    "element normal urgent " = {
      text-color = urgent;
    };

    "element normal active " = {
      text-color = accent;
    };

    "element alternate active " = {
      text-color = accent;
    };

    "element selected active " = {
      text-color = accent;
    };

    "element selected " = {
      background-color = bg3;
    };

    "element selected urgent " = {
      background-color = urgent;
    };

    element-icon = {
      size = l " 1.5em";
    };

    element-text = {
      text-color = l "inherit";
    };
  };
in {
  home.packages = [
    (
      pkgs.writeShellScriptBin "rofi-wifi-menu" (builtins.readFile (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/zbaylin/rofi-wifi-menu/refs/heads/master/rofi-wifi-menu.sh";
        sha256 = "0gilv2q4l7synn1labwzw3bm4xy4h1z2l7kh1jhjyfxn3xpx7fnc";
      }))
    )
  ];

  programs = {
    rofi = with pkgs; {
      enable = true;
      package = rofi-wayland;
      plugins = [rofi-emoji rofi-calc rofi-games rofi-power-menu rofi-mpd];
      cycle = true;
      terminal = "wezterm";
      # theme = windows-11-list;
      theme = macos;
    };

    rbw = {
      enable = true;
      settings.email = config.programs.git.userEmail;
      package = pkgs.rofi-rbw-wayland;
    };
  };
}
