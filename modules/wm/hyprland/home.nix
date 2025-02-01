{
  pkgs,
  lib,
  config,
  inputs,
  system,
  pkgs-stable,
  ...
}: let
  cfg = config.hyprland;
in {
  imports = [
    ../wayland/home.nix
  ];

  options.hyprland.enable = lib.mkEnableOption "enable hyprland home level";

  config = lib.mkIf cfg.enable {
    programs.hyprlock.enable = true;

    home.packages = with pkgs; [
      hyprsunset
      hyprpolkitagent
      # hyprsysteminfo
    ];
    wayland.windowManager.hyprland = {
      enable = true; # enable Hyprland
      plugins = [
        # inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
        inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
        # inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
        # inputs.hyprland-plugins.packages.${pkgs.system}.hyprwinwrap # windows as wallpapers
      ];

      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      settings = {
        experimental = {
          hdr = false;
        };
        misc = {
          disable_hyprland_logo = true;
        };
        input = {
          touchpad = {
            middle_button_emulation = true;
            disable_while_typing = true;
          };
        };

        # plugin = {
        #   hyprtrails = {
        #     color = "rgba(ffaa00ff)";
        #   };
        #   hyprbars = {
        #     # https://github.com/hyprwm/hyprland-plugins/tree/main/hyprbars
        #     bar_height = 20;
        #
        #     # example buttons (R -> L)
        #     # hyprbars-button = color, size, on-click
        #     hyprbars-button = [
        #       "rgb(ff4040), 10, 󰖭, hyprctl dispatch killactive"
        #       "rgb(eeee11), 10, , hyprctl dispatch fullscreen 1"
        #     ];
        #   };
        # hyprexpo = {
        #   columns = 3;
        #   gap_size = 5;
        #   bg_col = "rgb(111111)";
        #   workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1
        #
        #   enable_gesture = true; # laptop touchpad
        #   gesture_fingers = 3; # 3 or 4
        #   gesture_distance = 300; # how far is the "max"
        #   gesture_positive = true; # positive = swipe down. Negative = swipe up.
        # };
        # };

        "$mod" = "SUPER";
        "$terminal" = "wezterm";
        "$key" = "super_l";

        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
        };
        monitor = "eDP-1,1920x1080@144,0x0,1";

        exec-once =
          config.wayland.shared.startup
          ++ [
            #TODO: swayidle -w \\
            # 	timeout 300 'swaylock -f -c 000000' \\
            # 	timeout 600 'swaymsg "output * power off"' \\
            # 		resume 'swaymsg "output * power on"' \\
            # 	before-sleep 'swaylock -f -c 000000'
            "waybar"
            "hyprswitch init --show-title --size-factor 4.5 --workspaces-per-row 6 &"
          ];

        input = {
          kb_options = "ctrl:nocaps";
        };

        windowrule = let
          rule_map = rule: class_list: builtins.map (class: "${rule}, ${class}") class_list;
        in
          with config.wayland.shared.workspace_rules;
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
          "$mod,       mouse:272, movewindow"
          "$mod,       mouse:273, resizewindow"
        ];
        bind =
          [
            ",            keyboard_brightness_up_shortcut,   exec,          _tool_ctrl key up"
            ",            keyboard_brightness_down_shortcut, exec,          _tool_ctrl key down"

            "ALT,        F4, killactive,     "
            "$mod,       q,  exec,           hyprctl reload"
            "$mod,       p,  pin,            "
            "$mod,       f,  fullscreen,     "
            "$mod alt,   f,  exec,           hyprctl dispatch fakefullscreen, "
            "$mod shift, f,  togglefloating, "

            "alt,        tab, exec, hyprswitch gui --mod-key alt_l --key tab --close mod-key-release --reverse-key=mod=shift && hyprswitch dispatch"
            "alt shift,  tab, exec, hyprswitch gui --mod-key alt_l --key tab --close mod-key-release --reverse-key=mod=shift && hyprswitch dispatch -r"
            "$mod,       tab, exec, hyprswitch gui --mod-key super_l --key tab --close mod-key-release --reverse-key=mod=shift --switch-workspaces --filter-current-monitor && hyprswitch dispatch"
            "$mod shift, tab, exec, hyprswitch gui --mod-key super_l --key tab --close mod-key-release --reverse-key=mod=shift --switch-workspaces --filter-current-monitor && hyprswitch dispatch -r"
          ]
          ++ (map ({
            mod ? "",
            exec,
            key,
          }: "${mod},${key},exec,${exec}")
          config.wayland.shared.bindexec)
          ++ (
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
        bindel = map ({
          mod ? "",
          exec,
          key,
        }: "${mod},${key},exec,${exec}")
        config.wayland.shared.bindexec_el;
      };

      extraConfig = let
        submaps = {
          resize = {
            binding = "";
            bindings = {
              binde = [
                ", l, resizeactive, 10 0"
                ", h, resizeactive, -10 0"
                ", k, resizeactive, 0 -10"
                ", j, resizeactive, 0 10"
              ];
            };
          };
          wallpaper = {
            binding = "super, l";
            bindings = {
              binde = [
                ", r, exec, randbg.sh"
                ", l, exec, lastbg.sh"
                ", n, exec, nextbg.sh"
                ", p, exec, prevbg.sh"
              ];
            };
            submaps = {
              gowall = {
                binding = "g";
                bindings = {
                  bind = [
                    ", r, exec, GO_WALL=nix randbg.sh"
                    ", l, exec, GO_WALL=nix lastbg.sh"
                    ", n, exec, GO_WALL=nix nextbg.sh"
                    ", p, exec, GO_WALL=nix prevbg.sh"
                  ];
                };
                submaps = {
                  invert = {
                    binding = "i";
                    bindings = {
                      bind = [
                        ", r, exec, GO_WALL_INVERT=1 GO_WALL=nix randbg.sh"
                        ", l, exec, GO_WALL_INVERT=1 GO_WALL=nix lastbg.sh"
                        ", n, exec, GO_WALL_INVERT=1 GO_WALL=nix nextbg.sh"
                        ", p, exec, GO_WALL_INVERT=1 GO_WALL=nix prevbg.sh"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
        string = '''';
      in ''
        bind = super, r, submap, resize

        submap = resize

        binde = , l, resizeactive, 10 0
        binde = , h, resizeactive, -10 0
        binde = , k, resizeactive, 0 -10
        binde = , j, resizeactive, 0 10

        bind = , escape, submap, reset

        submap = reset

        bind = super, w, submap, wallpaper

        submap = wallpaper

        bind = , r, exec,   randbg.sh
        bind = , l, exec,   lastbg.sh
        bind = , n, exec,   nextbg.sh
        bind = , p, exec,   prevbg.sh

        bind = , g, submap,   gowall
        	submap = gowall
        	bind = , r, exec,   GO_WALL=nix randbg.sh
        	bind = , l, exec,   GO_WALL=nix lastbg.sh
        	bind = , n, exec,   GO_WALL=nix nextbg.sh
        	bind = , p, exec,   GO_WALL=nix prevbg.sh
        	bind = , escape, submap, wallpaper

        	bind = , i, submap, invert_gowall
        		submap = invert_gowall
        		bind = , r, exec,   GO_WALL_INVERT=1 GO_WALL=nix randbg.sh
        		bind = , l, exec,   GO_WALL_INVERT=1 GO_WALL=nix lastbg.sh
        		bind = , n, exec,   GO_WALL_INVERT=1 GO_WALL=nix nextbg.sh
        		bind = , p, exec,   GO_WALL_INVERT=1 GO_WALL=nix prevbg.sh
        		bind = , escape, submap, gowall
        		submap = gowall

        	submap = wallpaper

        bind = , escape, submap, reset

        submap = reset
      '';
    };
  };
}
