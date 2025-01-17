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
  options.hyprland_home.enable = lib.mkEnableOption "enable hyprland home level";

  config = lib.mkIf cfg.enable {
    programs.kitty.enable = true; # required for the default Hyprland config
    home.packages = with pkgs; [
      grimblast
      light
      pkgs.${browser}
      pkgs.${terminal}
      pkgs.${media_player}
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
        bindm = [
          "$mod,               mouse:272,             movewindow"
          "$mod,               mouse:273,             resizewindow"
        ];
        bind =
          [
            "$mod,             q,                     reload"
            "$mod Shift,       q,                     restart"

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
