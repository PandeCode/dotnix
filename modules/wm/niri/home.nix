{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  h = "/home/${config.home.username}";
in {
  imports = [
    ../wayland/home.nix
    inputs.niri.homeModules.niri
    inputs.niri.homeModules.stylix
  ];

  nixpkgs.overlays = [inputs.niri.overlays.niri];

  dotnix.symlinkPairs = [
    ["${h}/dotnix/config/niri/shaders/open.glsl" "${h}/.config/niri/shaders/open.glsl"]
    ["${h}/dotnix/config/niri/shaders/close.glsl" "${h}/.config/niri/shaders/close.glsl"]
    ["${h}/dotnix/config/niri/shaders/resize.glsl" "${h}/.config/niri/shaders/resize.glsl"]
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
    settings = with builtins; let
      splitBySpace = v: filter isString (split "[ ]+" v);
      joinByPlus = v:
        foldl' (a: b:
          a
          + (
            if a == ""
            then ""
            else "+"
          )
          + b) "" (splitBySpace v);
    in {
      prefer-no-csd = true;

      spawn-at-startup = map (v: {argv = v;}) ([
          ["xwayland-satellite"]
          ["bash" "-c" "waybar -c $(get_niri_waybar.sh)"]
        ]
        ++ map splitBySpace config.wayland.shared.startup);
      switch-events = {
        tablet-mode-on.action.spawn = ["gsettings" "set" "org.gnome.desktop.a11y.applications" "screen-keyboard-enabled" "true"];
        tablet-mode-off.action.spawn = ["gsettings" "set" "org.gnome.desktop.a11y.applications" "screen-keyboard-enabled" "false"];
      };
      outputs."eDP-1" = {
        enable = true;
        variable-refresh-rate = "on-demand";
        mode = {
          width = 1920;
          height = 1080;
          refresh = 144.0;
        };
        scale = 1;
      };
      input = {
        keyboard = {
          xkb = {
            layout = "us,es";
            options = "grp:win_space_toggle,ctrl:nocaps";
          };
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
          accel-speed = 0.2;
          accel-profile = "flat";
          scroll-method = "two-finger";
          disabled-on-external-mouse = true;
        };
      };
      animations = {
        window-open = {
          custom-shader = "${h}/.config/niri/shaders/open.glsl";
          kind.easing = {
            curve = "linear";
            duration-ms = 250;
          };
        };
        window-close = {
          custom-shader = "${h}/.config/niri/shaders/close.glsl";
          kind.easing = {
            curve = "linear";
            duration-ms = 250;
          };
        };
        window-resize = {
          custom-shader = "${h}/.config/niri/shaders/resize.glsl";
          kind.easing = {
            curve = "linear";
            duration-ms = 250;
          };
        };
      };
      binds = with config.lib.niri.actions;
        (foldl' (a: b: a // b) {}
          ((
              map
              (n: {
                "Mod+${toString n}".action.focus-workspace = n;
              })
              (genList (x: x + 1) 9)
            )
            ++ (
              map
              (
                v: {
                  "${(
                    if v.mod == ""
                    then ""
                    else "${joinByPlus v.mod}+"
                  )}${v.key}".action.spawn =
                    splitBySpace v.exec;
                }
              )
              config.wayland.shared.bindexec
              ++ (
                map
                (
                  v: {
                    "${(
                      if v.mod == ""
                      then ""
                      else "${joinByPlus v.mod}+"
                    )}${v.key}" = {
                      allow-when-locked = true;
                      action.spawn =
                        splitBySpace v.exec;
                    };
                  }
                )
                config.wayland.shared.bindexec_el
              )
            )))
        // {
          "Super+h".action = focus-column-left;
          "Super+l".action = focus-column-right;
          "Super+j".action = focus-window-or-workspace-down;
          "Super+k".action = focus-window-or-workspace-up;

          "Super+Shift+h".action = consume-or-expel-window-left;
          "Super+Shift+l".action = consume-or-expel-window-right;

          "Super+Shift+j".action = move-window-to-workspace-down {focus = true;};
          "Super+Shift+k".action = move-window-to-workspace-up {focus = true;};

          "Super+Ctrl+l".action = set-column-width "+10%";
          "Super+Ctrl+h".action = set-column-width "-10%";

          "Super+Space".action = expand-column-to-available-width;
          "Super+Shift+Space".action = maximize-column;

          "Super+f" = {
            action = fullscreen-window;
            repeat = false;
          };
          "Super+Alt+f" = {
            action = toggle-windowed-fullscreen;
            repeat = false;
          };
          "Super+Shift+f" = {
            action = toggle-window-floating;
            repeat = false;
          };

          "Super+Shift+q".action = quit {skip-confirmation = true;};

          "Super+Tab".action = toggle-overview;
          "Super+Slash".action = show-hotkey-overlay;
          "Alt+f4".action = close-window;

          # "Print".action = screenshot {show-pointer = false;};
        };
    };
  };

  #
  #   # finalConfig =
  #   #   /*
  #   #   kdl
  #   #   */
  #   #   ''
  #   #     overview {
  #   #         zoom 0.25;
  #   #         // backdrop-color "#777777";
  #   #     }
  #   #     gestures {
  #   #         hot-corners {
  #   #             off
  #   #         }
  #   #     }
  #   #   '';
  #
  #   settings = {

  #
  #     prefer-no-csd = true;
  #
  #     workspaces = {
  #       ws_1 = {};
  #       ws_2 = {};
  #       ws_3 = {};
  #       ws_4 = {};
  #       ws_5 = {};
  #     };
  #     window-rules =
  #       [
  #         {
  #           open-maximized = true;
  #           draw-border-with-background = false;
  #           clip-to-geometry = true;
  #           geometry-corner-radius = rec {
  #             bottom-left = 8.0;
  #             bottom-right = bottom-left;
  #             top-left = bottom-left;
  #             top-right = bottom-left;
  #           };
  #           border = {width = 2;};
  #         }
  #         {
  #           matches = [{app-id = "^baba$";}];
  #           baba-is-float = true;
  #         }
  #         {
  #           matches = [{is-window-cast-target = true;}];
  #
  #           focus-ring = {
  #             active = {color = "#f38ba8";};
  #             inactive = {color = "#7d0d2d";};
  #           };
  #
  #           border = {
  #             inactive = {color = "#7d0d2d";};
  #           };
  #
  #           shadow = {
  #             color = "#7d0d2d70";
  #           };
  #
  #           tab-indicator = {
  #             active = {color = "#f38ba8";};
  #             inactive = {color = "#7d0d2d";};
  #           };
  #         }
  #
  #         {
  #           matches = [{is-active = false;}];
  #           opacity = 0.95;
  #         }
  #         {
  #           matches = [{app-id = "zen";}];
  #           variable-refresh-rate = true;
  #           border = {width = 0;};
  #         }
  #
  #         {
  #           matches =
  #             lib.flatten
  #             (map (
  #                 v:
  #                   if builtins.isString v && builtins.substring 0 6 v == "title:"
  #                   then [{title = builtins.substring 6 (builtins.stringLength v) v;}]
  #                   else [{app-id = v;} {title = v;}]
  #               )
  #               config.wayland.shared.workspace_rules.float);
  #           open-floating = true;
  #         }
  #         # { # TODO Wait for niri devs
  #         #   matches =
  #         #     lib.flatten
  #         #     (map (
  #         #         v:
  #         #           if builtins.isString v && builtins.substring 0 6 v == "title:"
  #         #           then [{title = builtins.substring 6 (builtins.stringLength v) v;}]
  #         #           else [{app-id = v;} {title = v;}]
  #         #       )
  #         #       config.wayland.shared.workspace_rules.pin);
  #         #   pin = true;
  #         # }
  #       ]
  #       ++ lib.flatten (
  #         map (ws: {
  #           matches =
  #             lib.flatten
  #             (map (
  #                 v:
  #                   if builtins.isString v && builtins.substring 0 6 v == "title:"
  #                   then [{title = builtins.substring 6 (builtins.stringLength v) v;}]
  #                   else [{app-id = v;} {title = v;}]
  #               )
  #               config.wayland.shared.workspace_rules.${ws});
  #           open-on-workspace = ws;
  #         }) ["ws_1" "ws_2" "ws_3" "ws_4" "ws_5"]
  #       )
  #       # ++ m "ws_1"
  #       # ++ m "ws_2"
  #       # ++ m "ws_3"
  #       # ++ m "ws_4"
  #       # ++ m "ws_5"
  #       # pin
  #       ;
  #     environment = {
  #       DISPLAY = ":0";
  #     };
  #     layout = {
  #       gaps = 8;
  #     };
  #     outputs."eDP-1" = {
  #       enable = true;
  #       variable-refresh-rate = "on-demand";
  #       mode = {
  #         width = 1920;
  #         height = 1080;
  #         refresh = 144.0;
  #       };
  #       scale = 1;
  #       # transform = "normal";
  #       # position x=1280 y=0
  #     };
  #     input = {
  #       keyboard = {
  #         xkb = {
  #           layout = "us,es";
  #           options = "grp:win_space_toggle,ctrl:nocaps";
  #         };
  #       };
  #
  #       touchpad = {
  #         tap = true;
  #         natural-scroll = true;
  #         accel-speed = 0.2;
  #         accel-profile = "flat";
  #         scroll-method = "two-finger";
  #         disabled-on-external-mouse = true;
  #       };
  #
  #       mouse = {
  #         natural-scroll = true;
  #         accel-speed = 0.2;
  #       };
  #
  #       trackpoint = {
  #         natural-scroll = true;
  #         middle-emulation = true;
  #       };
  #     };
  #

  #
  #     binds = with config.lib.niri.actions; let
  #       # binds = with (map (v : {action = v;}) config.lib.niri.actions); let
  #       sh = spawn "sh" "-c";
  #       ls = f: {
  #         allow-when-locked = true;
  #         action.spawn = f;
  #       };
  #       cd150 = f: {
  #         cooldown-ms = 150;
  #         action = f;
  #       };
  #     in rec {
  #       XF86AudioPlay = ls ["_tool_ctrl" "media" "toggle"];
  #       XF86AudioNext = ls ["_tool_ctrl" "media" "next"];
  #       XF86AudioPrev = ls ["_tool_ctrl" "media" "prev"];
  #       XF86AudioRaiseVolume = ls ["_tool_ctrl" "vol" "up"];
  #       XF86AudioLowerVolume = ls ["_tool_ctrl" "vol" "down"];
  #       XF86AudioMute = ls ["_tool_ctrl" "vol" "mute"];
  #       XF86AudioMicMute = ls ["_tool_ctrl" "mic" "mute"];
  #       XF86MonBrightnessUp = ls ["_tool_ctrl" "light" "up"];
  #       XF86MonBrightnessDown = ls ["_tool_ctrl" "light" "down"];
  #
  #       "Mod+TouchpadScrollDown" = XF86MonBrightnessDown;
  #       "Mod+TouchpadScrollUp" = XF86MonBrightnessUp;
  #
  #       "Mod+Shift+Slash".action = show-hotkey-overlay;
  #
  #       "Mod+e".action = spawn config.wayland.shared.explorer;
  #       "Mod+Return".action = spawn config.wayland.shared.terminal;
  #       "Ctrl+Alt+Delete".action = spawn "hyprlock";
  #       "Ctrl+Shift+Alt+Delete".action = quit;
  #
  #       "Mod+Shift+c".action = spawn "rofi-calc.sh";
  #       "Mod+Ctrl+c".action = spawn "calc-clip.sh";
  #
  #       "Mod+Alt+c".action = spawn "hyprpicker";
  #
  #       "Alt+space".action = spawn "rofi-run.sh";
  #       "Alt+Shift+space".action = spawn "rofi-run-pr.sh";
  #
  #       "Super+v".action = spawn "rofi-clip.sh";
  #       "Super+Shift+v".action = spawn "rofi-paste.sh";
  #
  #       "Super+Shift+b".action = sh "killall -9 waybar ; waybar -c $(get_niri_waybar.sh)";
  #
  #       "Mod+s".action = spawn "_tool_search";
  #
  #       "Alt+F4".action = close-window;
  #
  #       "Mod+H".action = focus-column-left;
  #       "Mod+L".action = focus-column-right;
  #
  #       "Mod+Ctrl+H".action = move-column-left;
  #       "Mod+Ctrl+L".action = move-column-right;
  #
  #       "Mod+J".action = focus-window-or-workspace-down;
  #       "Mod+K".action = focus-window-or-workspace-up;
  #       "Mod+Shift+J".action = move-window-down-or-to-workspace-down;
  #       "Mod+Shift+K".action = move-window-up-or-to-workspace-up;
  #
  #       "Mod+Home".action = focus-column-first;
  #       "Mod+End".action = focus-column-last;
  #       "Mod+Ctrl+Home".action = move-column-to-first;
  #       "Mod+Ctrl+End".action = move-column-to-last;
  #
  #       "Mod+Alt+H".action = focus-monitor-left;
  #       "Mod+Alt+J".action = focus-monitor-down;
  #       "Mod+Alt+K".action = focus-monitor-up;
  #       "Mod+Alt+L".action = focus-monitor-right;
  #
  #       "Mod+Shift+Alt+H".action = move-column-to-monitor-left;
  #       "Mod+Shift+Alt+J".action = move-column-to-monitor-down;
  #       "Mod+Shift+Alt+K".action = move-column-to-monitor-up;
  #       "Mod+Shift+Alt+L".action = move-column-to-monitor-right;
  #
  #       # "Mod+Shift+Page_Down".action = move-workspace-down;
  #       # "Mod+Shift+Page_Up ".action = move-workspace-up;
  #       "Mod+Shift+U".action = move-workspace-down;
  #       "Mod+Shift+I".action = move-workspace-up;
  #
  #       # You can bind mouse wheel scroll ticks using the following syntax.
  #       # These binds will change direction based on the natural-scroll setting.
  #       #
  #       # To avoid scrolling through workspaces really fast, you can use
  #       # the cooldown-ms property. The bind will be rate-limited to this value.
  #       # You can set a cooldown on any bind, but it's most useful for the wheel.
  #
  #       # "Mod+WheelScrollDown" = cd150 focus-workspace-down;
  #       # "Mod+WheelScrollUp" = cd150 focus-workspace-up;
  #       # "Mod+Ctrl+WheelScrollDown" = cd150 move-column-to-workspace-down;
  #       # "Mod+Ctrl+WheelScrollUp" = cd150 move-column-to-workspace-up;
  #
  #       # "Mod+WheelScrollRight".action = focus-column-right;
  #       # "Mod+WheelScrollLeft".action = focus-column-left;
  #       # "Mod+Ctrl+WheelScrollRight".action = move-column-right;
  #       # "Mod+Ctrl+WheelScrollLeft".action = move-column-left;
  #
  #       # Usually scrolling up and down with Shift in applications results in
  #       # horizontal scrolling; these binds replicate that.
  #       # "Mod+Shift+WheelScrollDown".action = focus-column-right;
  #       # "Mod+Shift+WheelScrollUp".action = focus-column-left;
  #       # "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
  #       # "Mod+Ctrl+Shift+WheelScrollUp ".action = move-column-left;
  #
  #       # You can refer to workspaces by index. However, keep in mind that
  #       # niri is a dynamic workspace system, so these commands are kind of
  #       #"best effort". Trying to refer to a workspace index bigger than
  #       # the current workspace count will instead refer to the bottommost
  #       # (empty) workspace.
  #       #
  #       # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
  #       # will all refer to the 3rd workspace.
  #       "Mod+1".action = focus-workspace 1;
  #       "Mod+2".action = focus-workspace 2;
  #       "Mod+3".action = focus-workspace 3;
  #       "Mod+4".action = focus-workspace 4;
  #       "Mod+5".action = focus-workspace 5;
  #       "Mod+6".action = focus-workspace 6;
  #       "Mod+7".action = focus-workspace 7;
  #       "Mod+8".action = focus-workspace 8;
  #       "Mod+9".action = focus-workspace 9;
  #
  #       # "Mod+Ctrl+1".action = move-column-to-workspace 1;
  #       # "Mod+Ctrl+2".action = move-column-to-workspace 2;
  #       # "Mod+Ctrl+3".action = move-column-to-workspace 3;
  #       # "Mod+Ctrl+4".action = move-column-to-workspace 4;
  #       # "Mod+Ctrl+5".action = move-column-to-workspace 5;
  #       # "Mod+Ctrl+6".action = move-column-to-workspace 6;
  #       # "Mod+Ctrl+7".action = move-column-to-workspace 7;
  #       # "Mod+Ctrl+8".action = move-column-to-workspace 8;
  #       # "Mod+Ctrl+9".action = move-column-to-workspace 9;
  #       #
  #       # "Mod+Shift+1".action = move-window-to-workspace 1;
  #       # "Mod+Shift+2".action = move-window-to-workspace 2;
  #       # "Mod+Shift+3".action = move-window-to-workspace 3;
  #       # "Mod+Shift+4".action = move-window-to-workspace 4;
  #       # "Mod+Shift+5".action = move-window-to-workspace 5;
  #       # "Mod+Shift+6".action = move-window-to-workspace 6;
  #       # "Mod+Shift+7".action = move-window-to-workspace 7;
  #       # "Mod+Shift+8".action = move-window-to-workspace 8;
  #       # "Mod+Shift+9".action = move-window-to-workspace 9;
  #
  #       # Switches focus between the current and the previous workspace.
  #       "Mod+grave".action = focus-workspace-previous;
  #
  #       # The following binds move the focused window in and out of a column.
  #       # If the window is alone, they will consume it into the nearby column to the side.
  #       # If the window is already in a column, they will expel it out.
  #       "Mod+BracketLeft".action = consume-or-expel-window-left;
  #       "Mod+BracketRight".action = consume-or-expel-window-right;
  #
  #       "Mod+Tab".action = toggle-overview;
  #
  #       # Consume one window from the right to the bottom of the focused column.
  #       "Mod+Comma".action = consume-window-into-column;
  #       # Expel the bottom window from the focused column to the right.
  #       "Mod+Period".action = expel-window-from-column;
  #
  #       "Mod+R".action = switch-preset-column-width;
  #       "Mod+Shift+R".action = switch-preset-window-height;
  #       "Mod+Ctrl+R".action = reset-window-height;
  #
  #       "Mod+Shift+F".action = maximize-column;
  #       "Mod+F".action = fullscreen-window;
  #
  #       "Mod+C".action = center-column;
  #
  #       # Finer width adjustments.
  #       # This command can also:
  #       # * set width in pixels:"1000"
  #       # * adjust width in pixels:"-5" or"+5"
  #       # * set width as a percentage of screen width:"25%"
  #       # * adjust width as a percentage of screen width:"-10%" or"+10%"
  #       # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
  #       # set-column-width"100" will make the column occupy 200 physical screen pixels.
  #       "Mod+Minus".action = set-column-width "-10%";
  #       "Mod+Equal".action = set-column-width "+10%";
  #
  #       "Mod+Alt+Minus".action = set-window-height "-10%";
  #       "Mod+Alt+Equal".action = set-window-height "+10%";
  #
  #       # Move the focused window between the floating and the tiling layout.
  #       "Mod+alt+f".action = toggle-window-floating;
  #       "Mod+shift+space".action = switch-focus-between-floating-and-tiling;
  #
  #       # Actions to switch layouts.
  #       # Note: if you uncomment these, make sure you do NOT have
  #       # a matching layout switch hotkey configured in xkb options above.
  #       # Having both at once on the same hotkey will break the switching,
  #       # since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
  #       # "Mod+Comma".action = switch-layout "next";
  #       # "Mod+Period".action = switch-layout "prev";
  #
  #       "Print".action = screenshot;
  #       # "Ctrl+Print".action = screenshot-screen;
  #       "Alt+Print".action = screenshot-window;
  #
  #       "Mod+Shift+P".action = power-off-monitors;
  #     };
  #   };
  #   # config = builtins.readFile ../../../config/niri/config.kdl;
  # };
}
