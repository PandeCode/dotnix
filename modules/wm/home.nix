{
  pkgs,
  lib,
  config,
  sharedConfig,
  ...
}: let
  _bind = mod: key: exec: {inherit mod key exec;};
  mod = _bind "super";
  nomod = _bind "";
in {
  imports = [
    ../programs/spotify.nix
    ../programs/rofi.nix
    ../programs/filepicker.nix
    ../programs/zen.nix
    ../programs/mpv.nix
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
              "nsxiv"
              "hyprbind"

              "title:Blender Preferences"
              "title:Picture-in-picture"

              "org.pulseaudio.pavucontrol"
              ".blueman-manager-wrapped"

              "annotate_toolbar" # zoom rubbish
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
          ws_2 = ["Browser" "Firefox" "Google-chrome" "Opera" "Navigator" "zen-twilight"];
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
          # "gsettings set org.gnome.desktop.interface cursor-theme '${config.home.pointerCursor.name}'"
          # "gsettings set org.gnome.desktop.interface cursor-size ${toString config.home.pointerCursor.size}"
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

          (_bind "super shift" "g" "gif.sh")
          (_bind "super ctrl" "v" "clipimg.sh")

          (nomod "XF86AudioPlay" "_tool_ctrl media toggle")
          (nomod "XF86AudioNext" "_tool_ctrl media next")
          (nomod "XF86AudioPrev" "_tool_ctrl media prev")

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
    programs = {
      vesktop = {
        enable = true;
        settings = {
          appBadge = false;
          arRPC = true;
          checkUpdates = false;
          customTitleBar = false;
          disableMinSize = true;
          minimizeToTray = false;
          tray = false;
          splashBackground = "#000000";
          splashColor = "#ffffff";
          splashTheming = true;
          staticTitle = true;
          hardwareAcceleration = true;
          discordBranch = "stable";
        };
      };

      distrobox = {
        enable = true;
        settings = {
          # container_additional_volumes = "/example:/example1 /example2:/example3:ro";
          # container_always_pull = "1";
          # container_generate_entry = 0;
          # container_image_default = "registry.opensuse.org/opensuse/toolbox:latest";
          # container_init_hook = "~/.local/distrobox/a_custom_default_init_hook.sh";
          # container_manager = "docker";
          # container_manager_additional_flags = "--env-file /path/to/file --custom-flag";
          # container_name_default = "test-name-1";
          # container_pre_init_hook = "~/a_custom_default_pre_init_hook.sh";
          # container_user_custom_home = "$HOME/.local/share/container-home-test";
          # non_interactive = "1";
          # skip_workdir = "0";
        };

        containers = {
          random-things = {
            clone = "common-debian";
            entry = false;
          };
          common-debian = {
            additional_packages = "git";
            entry = true;
            image = "debian:13";
            init_hooks = [
              "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker"
              "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker-compose"
            ];
          };
        };
      };

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
          background-opacity = 0.8;
          background-blur = true;
          window-vsync = true;
          window-decoration = "server";
          clipboard-trim-trailing-spaces = true;
          clipboard-paste-protection = true;
          confirm-close-surface = false;

          custom-shader = "/home/${sharedConfig.user}/dotnix/config/ghostty/shader.glsl";
        };
      };
      alacritty.enable = true;
    };

    xdg = {
      mimeApps = {
        enable = true;
        defaultApplications = {
          "image/png" = "feh.desktop";
          "application/pdf" = "org.pwmt.zathura.desktop";
        };
      };
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
    };
    # services.fusuma = {
    #   enable = false;
    #   settings = {
    #     threshold = {
    #       swipe = 0.1;
    #     };
    #     interval = {
    #       swipe = 0.7;
    #     };
    #     swipe = {
    #       "3" = {
    #         left = {
    #           command = "notify-send fusma left 3";
    #         };
    #       };
    #     };
    #   };
    #
    # };
  };
}
