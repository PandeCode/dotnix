# my i3 settings, ported from old/modules/wm/i3/home.nix. startup, command
# binds and window rules come from wm.nix
{ lib, pkgs, ... }:

let
  mod = "Mod4";

  # i3status-rs icons; colors come with stylix
  statusHeader = ''
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
            names = [ "monospace" ];
            size = 12.0;
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

          "${mod}+Shift+p" =
            "floating enable, sticky enable, resize set width 640 px height 360 px, move position 80 px 80 px, border none";
        };
    };
  };
}
