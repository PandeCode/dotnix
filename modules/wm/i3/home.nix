{
  pkgs,
  lib,
  config,
  sharedConfig,
  ...
}:
with builtins;
with lib; let
  flattenListAttrsToAttr = lib.foldl' (a: b: a // b) {};
  mapBindingsToi3 = map ({
    mod,
    key,
    exec,
  }: {
    "${(replaceStrings [" " "super" "alt"] ["+" "Mod4" "Mod1"] (trim "${mod} ${key}"))}" = "exec ${exec}";
  });

  font = config.stylix.fonts.sansSerif.name;
  c = config.lib.stylix.colors;
in {
  imports = [
    ../x/home.nix
    ../../programs/i3status-rs.nix
  ];
  xsession.windowManager.i3 = {
    enable = true;
    extraConfig = ''
      for_window [class="feh"] floating enable, sticky enable, border pixel 0, move absolute position ${toString (sharedConfig.resolution.x - 720 + 20)} px 20 px
      for_window [class="Pqiv"] floating enable, sticky enable, border pixel 0, move absolute position 0 px 0 px

      for_window [title="Picture-in-Picture"] \
        floating enable, \
        sticky enable, \
        border none, \
        resize set width 480 px height 270 px, \
        move position 1440 px 24 px

    '';
    config = {
      gaps = {
        smartBorders = "on";
        smartGaps = true;

        inner = 8;
        outer = 4;
        top = 4;
        bottom = 6;
        left = 8;
        right = 8;
      };
      bars = [
        {
          mode = "dock";
          hiddenState = "hide";
          position = "top";
          workspaceButtons = true;
          workspaceNumbers = true;
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rs/xconfig.toml";
          fonts = {
            names = [font "monospace"];
            size = 8.0;
          };
          trayOutput = "primary";
          colors = {
            background = "#${c.base00}";
            statusline = "#${c.base05}";
            separator = "#${c.base03}";

            focusedWorkspace = {
              border = "#${c.base0A}";
              background = "#${c.base0D}";
              text = "#${c.base00}";
            };

            activeWorkspace = {
              border = "#${c.base03}";
              background = "#${c.base02}";
              text = "#${c.base05}";
            };

            inactiveWorkspace = {
              border = "#${c.base02}";
              background = "#${c.base01}";
              text = "#${c.base04}";
            };

            urgentWorkspace = {
              border = "#${c.base02}";
              background = "#${c.base0F}";
              text = "#${c.base00}";
            };

            bindingMode = {
              border = "#${c.base02}";
              background = "#${c.base0E}";
              text = "#${c.base00}";
            };
          };
        }
      ];
      window.titlebar = false;
      modifier = "Mod4";
      inherit (config.shared.x) terminal;
      keybindings =
        {
          "Mod1+F4" = "kill";
          "Mod4+f" = "fullscreen toggle";
          "Mod4+Ctrl+f" = "fullscreen toggle";
          "Mod4+Shift+f" = "floating toggle";

          "Mod4+h" = "exec i3ctl.sh focus_l";
          "Mod4+l" = "exec i3ctl.sh focus_r";
          "Mod4+j" = "exec i3ctl.sh focus_d";
          "Mod4+k" = "exec i3ctl.sh focus_u";

          "Mod4+Shift+h" = "exec i3ctl.sh move_l";
          "Mod4+Shift+l" = "exec i3ctl.sh move_r";
          "Mod4+Shift+j" = "exec i3ctl.sh move_d";
          "Mod4+Shift+k" = "exec i3ctl.sh move_u";

          "Mod4+Ctrl+h" = "exec i3ctl.sh resize_l";
          "Mod4+Ctrl+l" = "exec i3ctl.sh resize_r";
          "Mod4+Ctrl+j" = "exec i3ctl.sh resize_d";
          "Mod4+Ctrl+k" = "exec i3ctl.sh resize_u";

          "Mod4+Shift+p" = "floating enable, sticky enable, resize set width 640 px height 360 px, move position 80 px 80 px, border none";
        }
        // flattenListAttrsToAttr
        (
          (genList (
              j: let
                i = toString (j + 1);
              in {
                "Mod4+${i}" = "workspace number ${i}";
                "Mod4+shift+${i}" = "move container to workspace number ${i}";
              }
            )
            9)
          ++ (mapBindingsToi3 (config.x.shared.bindexec ++ config.x.shared.bindexec_el))
        );

      startup =
        map (command: {inherit command;}) (config.x.shared.startup ++ ["bg.sh last"]);
    };
  };
}
