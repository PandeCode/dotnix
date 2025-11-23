{
  pkgs,
  lib,
  config,
  ...
}:
with builtins;
with lib; let
  flattenListAttrsToAttr = lib.foldl' (a: b: a // b) {};
  mapBindingsToSway = map ({
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
    ../wayland/home.nix
    ../../programs/i3status-rs.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    extraConfig = ''
      # Window rules
      for_window [class="feh"] floating enable, sticky enable, border pixel 0, move absolute position 0 px 0 px
      for_window [class="Pqiv"] floating enable, sticky enable, border pixel 0, move absolute position 0 px 0 px
      for_window [app_id="feh"] floating enable, sticky enable, border pixel 0, move absolute position 0 px 0 px
      for_window [app_id="pqiv"] floating enable, sticky enable, border pixel 0, move absolute position 0 px 0 px

      for_window [title="Picture-in-Picture"] \
        floating enable, \
        sticky enable, \
        border none, \
        resize set width 480 px height 270 px, \
        move position 1440 px 24 px

      # Keyboard input
      input type:keyboard {
        xkb_options ctrl:nocaps,grp:win_space_toggle
        # xkb_layout us,es
      }

      ${builtins.readFile ../../../config/sway/swayfx.conf}
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
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rs/wayconfig.toml";
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
      inherit (config.wayland.shared) terminal;

      keybindings =
        {
          "Mod1+F4" = "kill";
          "Mod4+f" = "fullscreen toggle";
          "Mod4+Ctrl+f" = "fullscreen toggle";
          "Mod4+Shift+f" = "floating toggle";

          "Mod4+Shift+p" = "floating enable, sticky enable, resize set width 640 px height 360 px, move position 80 px 80 px, border none";

          "Mod4+h" = "exec swayctl.sh focus_l";
          "Mod4+l" = "exec swayctl.sh focus_r";
          "Mod4+j" = "exec swayctl.sh focus_d";
          "Mod4+k" = "exec swayctl.sh focus_u";

          "Mod4+Shift+h" = "exec swayctl.sh move_l";
          "Mod4+Shift+l" = "exec swayctl.sh move_r";
          "Mod4+Shift+j" = "exec swayctl.sh move_d";
          "Mod4+Shift+k" = "exec swayctl.sh move_u";

          "Mod4+Ctrl+h" = "exec swayctl.sh resize_l";
          "Mod4+Ctrl+l" = "exec swayctl.sh resize_r";
          "Mod4+Ctrl+j" = "exec swayctl.sh resize_d";
          "Mod4+Ctrl+k" = "exec swayctl.sh resize_u";
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
          ++ (mapBindingsToSway (config.wayland.shared.bindexec ++ config.wayland.shared.bindexec_el))
        );

      startup =
        map (command: {inherit command;}) (config.wayland.shared.startup ++ ["bg.sh last"]);
    };
  };
}
