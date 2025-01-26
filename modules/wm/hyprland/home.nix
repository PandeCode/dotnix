{
  pkgs,
  lib,
  config,
  inputs,
  system,
  pkgs-stable,
  ...
}: let
  cfg = config.hyprland_home;
  browser = "google-chrome";
  terminal = "wezterm";
  explorer = "nautilus";
  music_player = "spotify";
in {
  imports = [
    ../../programs/waybar.nix
    ../../programs/rofi.nix
  ];

  options.hyprland_home.enable = lib.mkEnableOption "enable hyprland home level";

  config = lib.mkIf cfg.enable {
    waybar.enable = true;
    rofi.enable = true;
    # beatprints.enable = true;

    services.swaync.enable = true;
    # services.dunst = { enable = true; };
    # services.avizo.enable = true;

    programs = {
      kitty.enable = true;
      alacritty.enable = true;
      hyprlock.enable = true;
    };

    home.packages = with pkgs; [
      inputs.zen-browser.packages."${system}".default

      # (import ../../../derivations/beatprints.nix {
      # inherit lib pkgs;
      # pkgs = pkgs-stable;
      # })

      python3Packages.pygobject3
      (import ../../../derivations/notify-send-py.nix {inherit lib pkgs;})

      translate-shell

      woomer
      grimblast
      light
      brightnessctl
      pamixer
      wl-clipboard
      cliphist
      xdg-utils
      slurp
      grim
      playerctl

      hyprpicker
      hyprlock
      hyprsunset
      hyprpolkitagent
      # hyprsysteminfo

      pkgs.${explorer}
      pkgs.${browser}
      pkgs.${terminal}
      # pkgs.${music_player} # handled by spicetify
      (writeShellScriptBin "_tool_media_info" ''${builtins.readFile ../../../bin/_tool_media_info}'')
      (writeShellScriptBin "_tool_riot" ''${builtins.readFile ../../../bin/_tool_riot}'')
      (writeShellScriptBin "_tool_search" ''${builtins.readFile ../../../bin/_tool_search}'')
      (writeShellScriptBin "_tool_menu" ''${builtins.readFile ../../../bin/_tool_menu}'')
    ];
    wayland.windowManager.hyprland = {
      enable = true; # enable Hyprland

      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      settings = {
        "$mod" = "SUPER";
        "$browser" = browser;
        "$music_player" = music_player;
        "$terminal" = terminal;
        "$explorer" = explorer;
        "$key" = "super_l";

        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
        };
        monitor = "eDP-1,1920x1080@144,0x0,1";

        exec-once = [
          #TODO: swayidle -w \\
          # 	timeout 300 'swaylock -f -c 000000' \\
          # 	timeout 600 'swaymsg "output * power off"' \\
          # 		resume 'swaymsg "output * power on"' \\
          # 	before-sleep 'swaylock -f -c 000000'
          "waybar"
          "$terminal"
          "nm-applet --indicator"
          #"blueman-applet"
          "wl-paste --type text --watch cliphist store" # Stores only text data
          "wl-paste --type image --watch cliphist store" # Stores only image data
          "systemctl --user start hyprpolkitagent"
          "hyprswitch init --show-title --size-factor 4.5 --workspaces-per-row 6 &"
          #"wl-paste --watch cliphist store"
        ];
        input = {
          kb_options = "ctrl:nocaps";
        };

        windowrule = let
          float =
            # WARN: Copied from DWM, WINTYPE, not sure if they count as classes
            ["DIALOG" "UTILITY" "TOOLBAR" "SPLASH" "_KDE_NET_WM_WINDOW_TYPE_OVERRIDE" "_NET_WM_WINDOW_TYPE_NORMAL"]
            ++ ["title:Blender Preferences" "vimb" "title:Picture-in-picture"];
          ws_1 = ["St" "st" "terminal" "alacritty" "kitty" "st-256color"];
          ws_2 = ["Browser" "Firefox" "Google-chrome" "Opera"];
          ws_3 = ["ModernGL" "Emacs" "emacs" "neovide" "Code" "Code - Insiders" "Blender"];
          ws_4 = ["hakuneko-desktop" "Unity" "unityhub" "UnityHub" "zoom"];
          ws_5 = ["Spotify" "vlc"];
          ws_6 = ["Mail" "Thunderbird"];
          ws_7 = ["riotclientux.exe" "leagueclient.exe" "Zenity" "zenity" "wine" "wine.exe" "explorer.exe"];
          noblur = ["firefox" "Google-chrome"];
          pin = ["title:Picture-in-picture"];
          rule_map = rule: class_list: builtins.map (class: "${rule}, ${class}") class_list;
        in
          [
            "animation popin, $terminal" # sets the animation style for $terminal
            "move 100 100, $terminal" # moves $terminal to 100 100
            "move cursor -50% -50%, $terminal" # moves $terminal to the center of the cursor
            "opacity 1.0 override 0.5 override 0.8 override, $terminal" # set opacity to 1.0 active, 0.5 inactive and 0.8 fullscreen for $terminal
            "rounding 10, terminal" # set rounding to 10 for kitty
          ]
          ++ rule_map "pin" pin
          ++ rule_map "float" float
          ++ rule_map "noblur" noblur
          ++ rule_map "workspace 1" ws_1
          ++ rule_map "workspace 2" ws_2
          ++ rule_map "workspace 3" ws_3
          ++ rule_map "workspace 4" ws_4
          ++ rule_map "workspace 5" ws_5
          ++ rule_map "workspace 6" ws_6
          ++ rule_map "workspace 7" ws_7;

        windowrulev2 = [
          "bordercolor rgb(00FF00), fullscreenstate:* 1" # set bordercolor to green if window's client fullscreen state is 1(maximize) (internal state can be anything)
          "bordercolor rgb(FF0000) rgb(880808), fullscreen:1" # set bordercolor to red if window is fullscreen
          "bordercolor rgb(FFFF00), title:.*Hyprland.*" # set bordercolor to yellow when title contains Hyprland
          "stayfocused,  class:(pinentry-)(.*)" # fix pinentry losing focus
          "pin,  class:(pinentry-)(.*)" # fix pinentry losing focus
        ];

        bindm = [
          "$mod,          mouse:272, movewindow"
          "$mod,          mouse:273, resizewindow"
        ];
        bind =
          [
            "$mod,            f, exec, hyprctl dispatch fullscreen"
            "$mod alt,        f, exec, hyprctl dispatch fakefullscreen"

            "$mod,            p, exec, hyprctl dispatch pin"

            "$mod shift,      f, exec, hyprctl dispatch togglefloating"
            "$mod ctrl ,      f, exec, _tool_riot"

            "$mod,       tab,                               exec,       $bin gui --mod-key $mod --key $key --max-switch-offset 9"

            # Keyboard workspace Monito
            "alt,         tab,                               exec,       hyprswitch gui --mod-key alt_l --key tab --close mod-key-release --reverse-key=mod=shift && hyprswitch dispatch"
            "alt shift,   tab,                               exec,       hyprswitch gui --mod-key alt_l --key tab --close mod-key-release --reverse-key=mod=shift && hyprswitch dispatch -r"
            "super,       tab,                               exec,       hyprswitch gui --mod-key super_l --key tab --close mod-key-release --reverse-key=mod=shift --switch-workspaces --filter-current-monitor && hyprswitch dispatch"
            "super shift, tab,                               exec,       hyprswitch gui --mod-key super_l --key tab --close mod-key-release --reverse-key=mod=shift --switch-workspaces --filter-current-monitor && hyprswitch dispatch -r"

            "$mod,         n,                             	exec,      swaync-client -t -sw"

            "$mod,        s,                             exec,       _tool_search"

            "alt,         space,                             exec,       rofi -show drun -show-icons"
            "alt shift,   space,                             exec,       rofi -show run -show-icons"

            "$mod,        v,                                 exec,       rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons"
            "$mod shift,  v,                                 exec,       bash -c \"cliphist list | rofi -dmenu | cliphist decode | xargs -I '{}' ydotool type '{}'\""

            "$mod,        q,                                 exec,       hyprctl reload"

            "$mod,        space,                             layoutmsg,  cyclenext"
            # behaves like xmonads promote feature (https://hackage.haskell.org/package/xmonad-contrib-0.17.1/docs/XMonad-Actions-Promote.html)
            "$mod shift,  space,                             layoutmsg,  swapwithmaster master"

            "$mod,        Return,                            exec,       $terminal"
            "$mod,        z,                                 exec,       woomer"
            "$mod,        e,                                 exec,       $explorer"
            "$mod,        c,                                 exec,       hyprpicker -a"
            "$mod,        l,                                 exec,       hyprlock"
            #"$mod,       l,                                 exec,       hyprsysteminfo"

            ",            Print,                             exec,       grimblast copy area"

            "ALT,         F4,                                killactive, "
            "$mod Shift,  a,                                 pin,        "

            ",            keyboard_brightness_up_shortcut,   exec,       _tool_ctrl key up"
            ",            keyboard_brightness_down_shortcut, exec,       _tool_ctrl key down"
            ",            XF86AudioMute,                     exec,       _tool_ctrl vol toggle"
            ",            XF86AudioPlay,                     exec,       _tool_ctrl media toggle"

            "$mod,        F1,                                exec,       _tool_ctrl vol toggle"
            "$mod,        F9,                                exec,       _tool_ctrl media toggle"

            ",            XF86AudioNext,                     exec,       _tool_ctrl media next"
            ",            XF86AudioPrev,                     exec,       _tool_ctrl media prev"
            "$mod,        F10,                               exec,       _tool_ctrl media next"
            "$mod,        F11,                               exec,       _tool_ctrl media prev"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mod,       code:1${toString i}, workspace,       ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );
        bindel = [
          # repeatable and lockscreen
          ", XF86AudioRaiseVolume,              exec, _tool_ctrl vol up"
          ", XF86AudioLowerVolume,              exec, _tool_ctrl vol down"
          ", XF86AudioMicMute,                  exec, _tool_ctrl mic down"
          ", XF86MonBrightnessUp,               exec, _tool_ctrl light up"
          ", XF86MonBrightnessDown,             exec, _tool_ctrl light down"

          "$mod, F2, exec, _tool_ctrl vol down"
          "$mod, F3, exec, _tool_ctrl vol up"
          "$mod, F4, exec, _tool_ctrl mic down"

          "$mod, F7, exec, _tool_ctrl light down"
          "$mod, F8, exec, _tool_ctrl light up"
        ];
      };
    };
  };
}
