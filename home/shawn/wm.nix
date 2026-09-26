# my window manager declaration: every wm takes its defaults from here
{ config, pkgs, ... }:

let
  inherit (config.dotnix.wm) terminal shell explorer;

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
in

{
  dotnix.wm = {
    terminal = "alacritty";
    shell = "fish";
    explorer = "nautilus";

    startup = [
      "${terminal} -e ${shell}"
      "blueman-applet"
      "nm-applet --indicator"
      "playerctld daemon"
    ];

    binds = [
      (bind [ "Super" ] "Return" "${terminal} -e ${shell}")
      (bind [ "Super" ] "e" explorer)
      (bind [ "Super" "Shift" ] "g" "gif.sh")
      (bind [ "Super" "Alt" "Ctrl" ] "f" "_tool_riot")
      (bind [ "Super" ] "p" "_tool_search")
      (bind [ "Super" "Shift" ] "c" "rofi-calc.sh")
      (bind [ "Alt" ] "space" "rofi-run.sh")
      (bind [ "Alt" "Shift" ] "space" "rofi-run-pr.sh")

      (bind [ ] "XF86AudioPlay" "_tool_ctrl media toggle")
      (bind [ ] "XF86AudioNext" "_tool_ctrl media next")
      (bind [ ] "XF86AudioPrev" "_tool_ctrl media prev")

      (locked [ ] "XF86AudioMute" "_tool_ctrl vol mute")
      (locked [ ] "XF86AudioRaiseVolume" "_tool_ctrl vol up")
      (locked [ ] "XF86AudioLowerVolume" "_tool_ctrl vol down")
      (locked [ ] "XF86AudioMicMute" "_tool_ctrl mic down")
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
        "bg.sh last"
        "picom -b"
      ];

      binds =
        let
          # scale the first connected output
          scale =
            factor: ''xrandr --output "$(xrandr | awk '/ connected/ { print $1; exit }')" --scale ${factor}'';
        in
        [
          (bind [ ] "Print" "maim -s | xclip -selection clipboard -t image/png")
          (bind [ "Super" ] "d" "dunstctl context")
          (bind [ "Super" "Shift" ] "d" "dunstctl close-all")
          (bind [ "Super" ] "b" "boomer")
          (bind [ "Super" ] "v" greenclip.copy)
          (bind [ "Super" "Shift" ] "v" greenclip.paste)
          (bind [ "Super" "Ctrl" ] "v" greenclip.restart)
          (bind [ "Super" "Shift" ] "minus" (scale "0.8x0.8"))
          (bind [ "Super" "Shift" ] "plus" (scale "1.2x1.2"))
        ];
    };

    wayland = {
      startup = [
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "waybar"
        "awww-daemon"
        "bg.sh last"
        "sunsetr"
      ];

      binds = [
        (bind [ "Super" "Ctrl" ] "v" "clipimg.sh")
        (bind [ "Super" ] "n" "swaync-client -t -sw")
        (bind [ "Super" ] "b" "woomer")
        (bind [ "Super" "Ctrl" "Shift" ] "c" "hyprpicker -a")
        (bind [ ] "Print" "grimblast copy area")
        (bind [ "Super" "Shift" ] "b" "toggle_waybar.sh")
        (bind [ "Super" "Shift" ] "r" "wayrec.sh")
        (bind [ "Super" "Shift" ] "p" "lock.sh")
        (bind [ "Super" ] "v" "rofi-clip.sh")
        (bind [ "Super" "Shift" ] "v" "rofi-clip-more.sh")
      ];
    };
  };
}
