{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.hyprland_home;
  browser = "google-chrome";
  terminal = "wezterm";
  media_player = "spotify";
in {
  imports = [
    ../../programs/waybar.nix
  ];

  options.hyprland_home.enable = lib.mkEnableOption "enable hyprland home level";

  config = lib.mkIf cfg.enable {
    waybar.enable = true;

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    programs.kitty.enable = true;
    programs.alacritty.enable = true;

    home.packages = with pkgs; [
      grimblast
      light
      brightnessctl
      wl-clipboard
      slurp
      grim

      pkgs.${browser}
      pkgs.${terminal}
      # pkgs.${media_player} # handled by spicetify
      (writeShellScriptBin "_tool_media_info" ''${builtins.readFile ../../../bin/_tool_media_info}'')
    ];
    wayland.windowManager.hyprland = {
      enable = true; # enable Hyprland

      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      settings = {
        "$mod" = "SUPER";
        "$browser" = browser;
        "$media_player" = media_player;
        "$terminal" = terminal;
        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
        };
        monitor = "DP-1,1920x1080@144,0x0,1";

        exec-once = ["waybar" "wezterm"];

        windowrule = [
          "animation popin, kitty" # sets the animation style for kitty
          "move 100 100, kitty" # moves kitty to 100 100
          "move cursor -50% -50%, kitty" # moves kitty to the center of the cursor
          "noblur, firefox" # disables blur for firefox
          "opacity 1.0 override 0.5 override 0.8 override, kitty" # set opacity to 1.0 active, 0.5 inactive and 0.8 fullscreen for kitty
          "rounding 10, kitty" # set rounding to 10 for kitty
          "rounding 10, wezterm" # set rounding to 10 for kitty
          "rounding 10, alacritty" # set rounding to 10 for kitty
        ];

        windowrulev2 = [
          "bordercolor rgb(00FF00), fullscreenstate:* 1" # set bordercolor to green if window's client fullscreen state is 1(maximize) (internal state can be anything)
          "bordercolor rgb(FF0000) rgb(880808), fullscreen:1" # set bordercolor to red if window is fullscreen
          "bordercolor rgb(FFFF00), title:.*Hyprland.*" # set bordercolor to yellow when title contains Hyprland
          "stayfocused,  class:(pinentry-)(.*)" # fix pinentry losing focus
        ];

        bindm = [
          "$mod,               mouse:272,             movewindow"
          "$mod,               mouse:273,             resizewindow"
        ];
        bind =
          [
            ", keyboard_brightness_up_shortcut, exec, brightnessctl -d *::kbd_backlight set +33%"
            ", keyboard_brightness_down_shortcut, exec, brightnessctl -d *::kbd_backlight set 33%-"

            "$mod,             q,                     reload,"
            "$mod Shift,       q,                     restart,"

            "$mod,             Return,                exec,            $terminal"
            "$mod,             b,                     exec,            $browser"
            "$mod,             s,                     exec,            $media_player"

            ",                 Print,                 exec,            grimblast copy area"

            "ALT,              F4,                    killactive,      "
            # stick window
            "$MOD SHIFT,       a,                     pin,             "
          ]
          ++ [
            '',                XF86AudioRaiseVolume,  exec,            "pactl set-sink-volume @DEFAULT_SINK@ 10%; dunstify 'Vol' -h int:value:$(pamixer --get-volume)"''
            '',                XF86AudioLowerVolume,  exec,            "pactl set-sink-volume @DEFAULT_SINK@ -10%; dunstify 'Vol' -h int:value:$(pamixer --get-volume)"''
            '',                XF86AudioMute,         exec,            "pactl set-sink-mute   @DEFAULT_SINK@ toggle; dunstify 'Mute' -h int:value:$(pamixer --get-volume)"''
            '',                XF86AudioMicMute,      exec,            "pactl set-source-mute @DEFAULT_SOURCE@ toggle; dunstify 'Mic Mute' -h int:value:$(pamixer --get-volume)"''
            '',                XF86MonBrightnessUp,   exec,            "light -A 5;dunstify 'Light:' -h int:value:$(light)"''
            '',                XF86MonBrightnessDown, exec,            "light -U 5;dunstify 'Light:' -h int:value:$(light)"''
            '',                XF86AudioPlay,         exec,            "playerctl play-pause; dunstify $(_tool_media_info)"''
            '',                XF86AudioNext,         exec,            "playerctl next;       dunstify $(_tool_media_info)"''
            '',                XF86AudioPrev,         exec,            "playerctl previous;   dunstify $(_tool_media_info)"''
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mod,       code:1${toString i},   workspace,       ${toString ws}"
                  "$mod SHIFT, code:1${toString i},   movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );
      };
    };
  };
}
