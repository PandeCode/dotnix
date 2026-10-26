{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  inherit (config.dotnix.wm) terminal explorer;

  rofiClip = ''rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}' -theme /tmp/launcher.rasi'';
  greenclip = {
    copy = rofiClip;
    # i3 runs binds through sh, so && works without a wrapper
    paste = ''${rofiClip} && sleep 0.5 && xdotool type "$(xclip -o -selection clipboard)"'';
    restart = "pkill greenclip && greenclip clear && greenclip daemon";
  };

  bind = mods: key: exec: { inherit mods key exec; };
  locked = mods: key: exec: {
    inherit mods key exec;
    locked = true;
  };

  # same key, same action in every session, with the program that fits it
  sessionBinds = [
    (bind [ "Super" ] "b" {
      x11 = "boomer";
      wayland = "woomer";
    })
    (bind [ "Super" ] "n" {
      x11 = "dunstctl context";
      wayland = "swaync-client -t -sw";
    })
    (bind [ "Super" "Shift" ] "n" {
      x11 = "dunstctl close-all";
      wayland = "swaync-client -C";
    })
    (bind [ "Super" ] "v" {
      x11 = greenclip.copy;
      wayland = "rofi-clip.sh";
    })
    (bind [ "Super" "Shift" ] "v" {
      x11 = greenclip.paste;
      wayland = "rofi-clip-more.sh";
    })
    (bind [ "Super" "Ctrl" "Shift" ] "c" {
      x11 = "xcolor -s clipboard";
      wayland = "hyprpicker -a";
    })
  ];

  forSession = session: map (b: b // { exec = b.exec.${session}; }) sessionBinds;
in

{
  dotnix.wm = {
    terminal = "ghostty";
    shell = "fish";
    explorer = "nautilus";

    # no -e: it would start a new ghostty instead of a window of the
    # running one, and ghostty starts the shell itself
    startup = [
      terminal
    ]
    ++ lib.lists.optional osConfig.services.blueman.enable "blueman-applet"
    ++ [
      "nm-applet --indicator"
      "playerctld daemon"
    ];

    binds = [
      (bind [ "Super" ] "Return" terminal)
      (bind [ "Super" ] "e" explorer)
      (bind [ "Super" "Shift" ] "g" "gif.sh")
      (bind [ "Super" ] "r" "_tool_riot")
      (bind [ "Super" ] "i" "info")
      (bind [ "Super" "Ctrl" ] "c" "_tool_clip")
      (bind [ "Super" ] "p" "_tool_search")
      (bind [ "Super" "Shift" ] "c" "rofi-calc.sh")
      (bind [ "Super" "Shift" ] "b" "rofi-rbw")
      (bind [ "Super" "Ctrl" ] "v" "clipimg.sh")
      (bind [ "Super" ] "Print" "screenshot screen")
      (bind [ "Super" "Shift" ] "Print" "screenshot area")
      (bind [ "Super" "Ctrl" ] "r" "record screen")
      (bind [ "Super" "Shift" ] "r" "record area")
      (bind [ "Super" "Shift" ] "p" "lock")
      (bind [ "Super" "Shift" ] "equal" "display-scale in")
      (bind [ "Super" "Shift" ] "minus" "display-scale out")
      (bind [ "Super" "Shift" ] "0" "display-scale reset")
      (bind [ "Alt" ] "space" "rofi-run.sh")
      (bind [ "Alt" "Shift" ] "space" "rofi-run-pr.sh")

      (bind [ ] "XF86AudioPlay" "_tool_ctrl media toggle")
      (bind [ ] "XF86AudioNext" "_tool_ctrl media next")
      (bind [ ] "XF86AudioPrev" "_tool_ctrl media prev")

      (locked [ ] "XF86AudioMute" "_tool_ctrl vol mute")
      (locked [ ] "XF86AudioRaiseVolume" "_tool_ctrl vol up")
      (locked [ ] "XF86AudioLowerVolume" "_tool_ctrl vol down")
      (locked [ ] "XF86AudioMicMute" "_tool_ctrl mic mute")
      (locked [ ] "XF86MonBrightnessUp" "_tool_ctrl light up")
      (locked [ ] "XF86MonBrightnessDown" "_tool_ctrl light down")
    ];

    rules = {
      float = [
        # window types from dwm
        "DIALOG"
        "UTILITY"
        "TOOLBAR"
        "SPLASH"
        "_KDE_NET_WM_WINDOW_TYPE_OVERRIDE"
        "_NET_WM_WINDOW_TYPE_NORMAL"

        "vimb"
        "Pqiv"
        "feh"
        "nsxiv"
        "hyprbind"

        "title:Blender Preferences"
        "title:Picture-in-picture"

        "org.pulseaudio.pavucontrol"
        ".blueman-manager-wrapped"
        "blueman-manager"

        # zoom
        "annotate_toolbar"
      ];

      pin = [
        "title:Picture-in-picture"
        "Pqiv"
        "hyprbind"
        "feh"
      ];

      noblur = [
        "firefox"
        "Google-chrome"
        "Pqiv"
        "feh"
      ];

      noshadow = [
        "zen-twilight"
        "title:Picture-in-picture"
      ];

      noborder = [
        "zen-twilight"
        "title:Picture-in-picture"
        "Pqiv"
        "feh"
      ];

      workspaces = {
        "1" = [
          "St"
          "st"
          "ghostty"
          "alacritty"
          "kitty"
          "st-256color"
        ];
        "2" = [
          "Browser"
          "Firefox"
          "Google-chrome"
          "Opera"
          "Navigator"
          "zen-twilight"
        ];
        "3" = [
          "ModernGL"
          "Emacs"
          "emacs"
          "neovide"
          "Code"
          "Code - Insiders"
          "Blender"
        ];
        "4" = [
          "Unity"
          "unityhub"
          "UnityHub"
          "zoom"
        ];
        "5" = [
          "Spotify"
          "vlc"
        ];
        "6" = [
          "Mail"
          "Thunderbird"
          "betterbird"
        ];
        "7" = [
          "riotclientux.exe"
          "leagueclient.exe"
          "Zenity"
          "zenity"
          "wine"
          "wine.exe"
          "explorer.exe"
        ];
      };
    };

    x11 = {
      startup = [
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "xmodmap ~/.Xmodmap"
        "greenclip daemon"
        "dunst"
        "wall last"
        "picom -b"
      ];

      binds = forSession "x11" ++ [
        (bind [ "Super" "Ctrl" "Shift" ] "v" greenclip.restart)
      ];
    };

    wayland = {
      startup = [
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "awww-daemon"
        "wall last"
        "sunsetr"
      ];

      binds = forSession "wayland";
    };
  };
}
