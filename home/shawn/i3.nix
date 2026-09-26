{
  config,
  lib,
  pkgs,
  ...
}:

let
  mod = "Mod4";

  c = config.lib.stylix.colors.withHashtag;
  font = config.stylix.fonts.sansSerif.name;

  statusHeader = ''
    [theme.overrides]
    idle_bg = "${c.base00}"
    idle_fg = "${c.base05}"
    good_bg = "${c.base00}"
    good_fg = "${c.base0B}"
    warning_bg = "${c.base00}"
    warning_fg = "${c.base0A}"
    critical_bg = "${c.base00}"
    critical_fg = "${c.base0F}"
    info_bg = "${c.base00}"
    info_fg = "${c.base0D}"
    alternating_tint_bg = "${c.base01}"
    alternating_tint_fg = "${c.base05}"
    separator_bg = "${c.base00}"

    [icons]
    icons            = "awesome6"
    [icons.overrides]
    ban              = "\uf05e" # fa-ban
    wifi             = "\uf1eb" # fa-wifi
    signal           = "\uf012" # fa-signal
    exchange         = "\uf362" # fa-exchange-alt
    tachometer       = "\uf0e4" # fa-tachometer
    volume_empty     = "\ue04e" # volume_mute
    volume_full      = "\ue050" # volume_up
    volume_half      = "\ue04d" # volume_down
    volume_muted     = "\ue04f" # volume_off
    microphone_full  = "\ue029" # mic
    microphone_half  = "\ue029" # mic
    microphone_empty = "\ue02a" # mic_none
    microphone_muted = "\ue02b" # mic_off
  '';
in

{
  dotnix.i3.enable = true;

  xdg.configFile."i3status-rs/xconfig.toml".text = lib.strings.concatStringsSep "\n" [
    statusHeader
    (builtins.readFile ../../config/i3status-rs/xconfig.toml)
    (builtins.readFile ../../config/i3status-rs/config.toml)
  ];

  xsession.windowManager.i3 = {
    extraConfig = ''
      for_window [class="feh"] floating enable, sticky enable, border pixel 0, move absolute position 1220 px 20 px
      for_window [class="Pqiv"] floating enable, sticky enable, border pixel 0, move absolute position 0 px 0 px

      for_window [title="Picture-in-Picture"] \
        floating enable, \
        sticky enable, \
        border none, \
        resize set width 480 px height 270 px, \
        move position 1440 px 24 px
    '';

    config = {
      modifier = mod;
      window.titlebar = false;

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
          statusCommand = "${lib.meta.getExe pkgs.i3status-rust} ~/.config/i3status-rs/xconfig.toml";
          fonts = {
            names = [
              font
              "monospace"
            ];
            size = 12.0;
          };
          colors = {
            background = c.base00;
            statusline = c.base05;
            separator = c.base03;

            focusedWorkspace = {
              border = c.base0A;
              background = c.base0D;
              text = c.base00;
            };
            activeWorkspace = {
              border = c.base03;
              background = c.base02;
              text = c.base05;
            };
            inactiveWorkspace = {
              border = c.base02;
              background = c.base01;
              text = c.base04;
            };
            urgentWorkspace = {
              border = c.base02;
              background = c.base0F;
              text = c.base00;
            };
            bindingMode = {
              border = c.base02;
              background = c.base0E;
              text = c.base00;
            };
          };
        }
      ];

      keybindings =
        lib.attrsets.listToAttrs (
          lib.lists.concatMap (
            n:
            let
              i = toString n;
            in
            [
              {
                name = "${mod}+${i}";
                value = "workspace number ${i}";
              }
              {
                name = "${mod}+Shift+${i}";
                value = "move container to workspace number ${i}";
              }
            ]
          ) (lib.lists.range 1 9)
        )
        // {
          "Mod1+F4" = "kill";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+Ctrl+f" = "fullscreen toggle";
          "${mod}+Shift+f" = "floating toggle";

          "${mod}+h" = "exec i3ctl.sh focus_l";
          "${mod}+l" = "exec i3ctl.sh focus_r";
          "${mod}+j" = "exec i3ctl.sh focus_d";
          "${mod}+k" = "exec i3ctl.sh focus_u";

          "${mod}+Shift+h" = "exec i3ctl.sh move_l";
          "${mod}+Shift+l" = "exec i3ctl.sh move_r";
          "${mod}+Shift+j" = "exec i3ctl.sh move_d";
          "${mod}+Shift+k" = "exec i3ctl.sh move_u";

          "${mod}+Ctrl+h" = "exec i3ctl.sh resize_l";
          "${mod}+Ctrl+l" = "exec i3ctl.sh resize_r";
          "${mod}+Ctrl+j" = "exec i3ctl.sh resize_d";
          "${mod}+Ctrl+k" = "exec i3ctl.sh resize_u";

          "${mod}+Ctrl+p" =
            "floating enable, sticky enable, resize set width 640 px height 360 px, move position 80 px 80 px, border none";
        };
    };
  };
}
