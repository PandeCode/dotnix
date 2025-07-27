{
  pkgs,
  lib,
  config,
  # inputs,
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
        inherit (sharedConfig) terminal explorer;
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

              "vimb"
              "Pqiv"
              "feh"
              "hyprbind"

              "title:Blender Preferences"
              "title:Picture-in-picture"
            ];
          pin = [
            "title:Picture-in-picture"

            "Pqiv"
            "hyprbind"
            "feh"
          ];
          noblur = ["firefox" "Google-chrome" "Pqiv" "feh"];

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

          ws_1 = ["St" "st" "ghostty" "alacritty" "kitty" "st-256color"];
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
          "gsettings set org.gnome.desktop.interface cursor-theme '${config.home.pointerCursor.name}'"
          "gsettings set org.gnome.desktop.interface cursor-size ${toString config.home.pointerCursor.size}"
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

          (_bind "super shift" "t" "touchpad.sh")
          (_bind "super alt ctrl" "f" "_tool_riot")
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
    home.sessionVariables = {
      TERMINAL = config.wm.shared.terminal;
      EXPLORER = config.wm.shared.explorer;
    };
    programs = {
      kitty = {
        enable = true;
        settings = {
          cursor_trail = 1;
        };
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

          # custom-shader = "./ghostty-shaders/gears-and-belts.glsl";
        };
      };
      alacritty.enable = true;
    };

    home = {
      packages = [
        pkgs.appimage-run
        # pkgs.spatial-shell

        # (pkgs.writeShellScriptBin "webcamize" (builtins.readFile (builtins.fetchurl {
        #   url = "https://github.com/cowtoolz/webcamize/raw/refs/heads/master/webcamize";
        #   sha256 = "13cqqzj5naw8fw1kash0v5lpxplx5hy887k9cypdz0r6g4inj66r";
        # })))
      ];
    };

    xdg = {
      desktopEntries = {
        systemctl-tui = {
          name = "Systemctl TUI";
          comment = "Launch systemctl-tui in terminal";
          exec = "${sharedConfig.terminal} --title=\"Systemctl TUI\" -e systemctl-tui";
          icon = "utilities-terminal";
          terminal = false;
          type = "Application";
          categories = ["System" "Utility"];
        };

        systemctl-tui-sudo = {
          name = "Systemctl TUI (sudo)";
          comment = "Launch systemctl-tui with sudo in terminal";
          exec = "${sharedConfig.terminal} --title=\"Systemctl TUI (sudo)\" -e bash -c \"sudo systemctl-tui\"";
          icon = "utilities-terminal";
          terminal = false;
          type = "Application";
          categories = ["System" "Utility"];
        };
        #
        # stacer = {
        #   name = "Stacer";
        #   comment = "System optimizer and monitor";
        #   exec = "stacer";
        #   icon = "stacer"; # Or fallback: "utilities-system-monitor"
        #   terminal = false;
        #   type = "Application";
        #   categories = ["System" "Utility"];
        # };
        #
        # stacer-root = {
        #   name = "Stacer (Root)";
        #   comment = "Launch Stacer with root privileges";
        #   exec = "pkexec stacer";
        #   icon = "stacer";
        #   terminal = false;
        #   type = "Application";
        #   categories = ["System" "Utility"];
        # };
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
      enable = false;
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
