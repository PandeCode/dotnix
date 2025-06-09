{
  pkgs,
  lib,
  inputs,
  sharedConfig,
  ...
}: let
  _bind = mod: key: exec: {inherit mod key exec;};
  mod = _bind "super";
  nomod = _bind "";
in {
  imports = [
    ../programs/rofi.nix
    # ../programs/swhkd.nix
  ];

  options.wm = {
    shared = lib.mkOption {
      default = rec {
        terminal = "ghostty";
        explorer = "nautilus";
        workspace_rules = {
          float =
            # WARN: Copied from DWM, WINTYPE, not sure if they count as classes
            [
              "DIALOG"
              "UTILITY"
              "TOOLBAR"
              "SPLASH"
              "_KDE_NET_WM_WINDOW_TYPE_OVERRIDE"
              "_NET_WM_WINDOW_TYPE_NORMAL"
              "title:Blender Preferences"
              "title:Picture-in-picture"
              "vimb"
              "Pqiv"
              "hyprbind"
            ];
          pin = [
            "title:Picture-in-picture"
            "Pqiv"
            "hyprbind"
          ];
          noblur = ["firefox" "Google-chrome"];

          noshadow = [
            "zen-twilight"
            "title:Picture-in-picture"
            "floating:1"
          ];

          noborder = [
            "zen-twilight"
            "title:Picture-in-picture"
            "floating:1"
          ];

          ws_1 = ["St" "st" terminal "alacritty" "kitty" "st-256color"];
          ws_2 = ["Browser" "Firefox" "Google-chrome" "Opera"];
          ws_3 = ["ModernGL" "Emacs" "emacs" "neovide" "Code" "Code - Insiders" "Blender"];
          ws_4 = ["hakuneko-desktop" "Unity" "unityhub" "UnityHub" "zoom"];
          ws_5 = ["Spotify" "vlc"];
          ws_6 = ["Mail" "Thunderbird"];
          ws_7 = ["riotclientux.exe" "leagueclient.exe" "Zenity" "zenity" "wine" "wine.exe" "explorer.exe"];
        };

        startup = [
          terminal
          "blueman-applet"
          "nm-applet --indicator"
        ];
        bindings = {
          cycle_layout = ["super" "space"];

          show_all_ws = ["super" "tab"];

          toggle_bar = ["super" "shift" "b"];

          pin_active = ["super" "p"];

          fullscreen_active = ["super" "f"];
          fake_fullscreen_active = ["super ctrl" "f"];

          floating_active = ["super shift" "f"];
          select_floating_active = ["super alt" "f"];

          kill_active_window = ["alt" "f4"];
          restart_wm = ["super" "q"];
          kill_wm = ["super" "shift" "f4"];

          alt_tab = ["alt" "tab"];
          shift_alt_tab = ["shift" "alt" "tab"];
        };
        bindexec = [
          (mod "Return" "${terminal}")
          (mod "e" "${explorer}")

          (_bind "super shift" "g" "find ~/Pictures/gifs/ -type f | shuf -n 1 | xargs -I{} pqiv -c -c -i '{}'")

          (nomod "XF86AudioPlay" "_tool_ctrl media toggle")
          (nomod "XF86AudioNext" "_tool_ctrl media next")
          (nomod "XF86AudioPrev" "_tool_ctrl media prev")

          (mod "t" "translate-clip.sh")
          (_bind "super shift" "t" "translate-img.sh")
          (_bind "super ctrl" "f" "_tool_riot")
          (mod "p" "_tool_search")

          (_bind "super shift" "c" "rofi-calc.sh")

          (_bind "alt" "space" "rofi-run.sh")
          (_bind "alt shift" "space" "rofi-run-pr.sh")
        ];
        bindexec_el = [
          (nomod "XF86AudioMute" "_tool_ctrl vol mute")
          (nomod "XF86AudioRaiseVolume" "_tool_ctrl vol up")
          (nomod "XF86AudioLowerVolume" "_tool_ctrl vol down")
          (nomod "XF86AudioMicMute" "_tool_ctrl mic down")
          (nomod "XF86MonBrightnessUp" "_tool_ctrl light up")
          (nomod "XF86MonBrightnessDown" "_tool_ctrl light down")
        ];
      };
    };
  };

  config = {
    programs = {
      kitty = {
        enable = true;
        shellIntegration = {
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
        };
      };
      ghostty = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        settings = {
          background-opacity = lib.mkForce 0.8;
          background-blur = lib.mkForce true;
          window-vsync = lib.mkForce true;
          window-decoration = lib.mkForce "server";
          clipboard-trim-trailing-spaces = lib.mkForce true;
          clipboard-paste-protection = lib.mkForce true;
          confirm-close-surface = lib.mkForce false;

          custom-shader = "./ghostty-shaders/gears-and-belts.glsl";
        };
      };
      alacritty.enable = true;
    };

    home.packages = [
      pkgs.spatial-shell

      # (pkgs.writeShellScriptBin "webcamize" (builtins.readFile (builtins.fetchurl {
      #   url = "https://github.com/cowtoolz/webcamize/raw/refs/heads/master/webcamize";
      #   sha256 = "13cqqzj5naw8fw1kash0v5lpxplx5hy887k9cypdz0r6g4inj66r";
      # })))
    ];

    xdg = {
      desktopEntries = {
        systemctl-tui = {
          name = "Systemctl TUI";
          comment = "Launch systemctl-tui in Ghostty";
          exec = "ghostty --title=\"Systemctl TUI\" -e systemctl-tui";
          icon = "utilities-terminal";
          terminal = false;
          type = "Application";
          categories = ["System" "Utility"];
        };

        systemctl-tui-sudo = {
          name = "Systemctl TUI (sudo)";
          comment = "Launch systemctl-tui with sudo in Ghostty";
          exec = "ghostty --title=\"Systemctl TUI (sudo)\" -e bash -c \"sudo systemctl-tui\"";
          icon = "utilities-terminal";
          terminal = false;
          type = "Application";
          categories = ["System" "Utility"];
        };

        stacer = {
          name = "Stacer";
          comment = "System optimizer and monitor";
          exec = "stacer";
          icon = "stacer"; # Or fallback: "utilities-system-monitor"
          terminal = false;
          type = "Application";
          categories = ["System" "Utility"];
        };

        stacer-root = {
          name = "Stacer (Root)";
          comment = "Launch Stacer with root privileges";
          exec = "pkexec stacer";
          icon = "stacer";
          terminal = false;
          type = "Application";
          categories = ["System" "Utility"];
        };
      };

      configFile = {
        "spatial/config-waybar".text = ''
          status_bar_name "waybar"
        '';
        "spatial/config-sway".text = ''
          status_bar_name "i3blocks"
        '';
        "spatial/config-i3".text = ''
          status_bar_name "i3blocks"
        '';
      };
    };
    services.fusuma = {
      enable = true;
      settings = {
        threshold = {
          swipe = 0.1;
        };
        interval = {
          swipe = 0.7;
        };
        swipe = {
          "3" = {
            left = {
              command = "notify-send fusma left 3";
            };
          };
        };
      };
    };
  };
}
