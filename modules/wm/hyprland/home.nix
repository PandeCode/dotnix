{
  pkgs,
  config,
  lib,
  sharedConfig,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  footalttab = false;
in {
  imports = [
    # inputs.hyprland.homeManagerModules.default
    ../wayland/home.nix
  ];

  home.packages = with pkgs; [
    hyprshade
    hyprprop
    hyprsunset
    foot
    fzf
    chafa
    jq
  ];

  xdg.configFile."hypr/hyprshade.toml".text =
    /*
    toml
    */
    ''
      [[shades]]
      name = "vibrance"
      default = true  # will be activated when no other shader is scheduled

      [[shades]]
      name = "blue-light-filter"
      start_time = 19:00:00
      end_time = 06:00:00   # optional if more than one shader has start_time
    '';

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    # package = lib.mkForce null;
    # portalPackage = lib.mkForce null;

    plugins = with pkgs.hyprlandPlugins; [
      hyprexpo
      hyprtrails
      hypr-dynamic-cursors
    ];

    settings = {
      env = "AQ_DRM_DEVICES,/dev/dri/card2:/dev/dri/card1";

      decoration = {
        dim_inactive = true;
        rounding = 8;
      };

      general = {
        gaps_out = 8;
      };

      input = {
        kb_options = "ctrl:nocaps";
        touchpad = {
          middle_button_emulation = true;
          disable_while_typing = true;
        };
      };

      misc = {
        disable_hyprland_logo = true;
      };
      plugin = {
        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(111111)";
          workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1

          enable_gesture = true; # laptop touchpad
          gesture_fingers = 3; # 3 or 4
          gesture_distance = 300; # how far is the "max"
          gesture_positive = true; # positive = swipe down. Negative = swipe up.
        };
      };

      "$key" = "super_l";

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };
      monitor = [
        "eDP-1, highrr, auto, 1"
        " , preferred, auto, 1"
      ];

      exec = [
        "hyprshade auto"
      ];
      exec-once =
        config.wayland.shared.startup
        ++ [
          "waybar"
          "hyprswitch init --show-title --size-factor 4.5 --workspaces-per-row 6 &"
        ];
      windowrule = let
        getName = str:
          if builtins.substring 0 6 str == "class:" || builtins.substring 0 6 str == "title:" || builtins.substring 0 6 str == "float:"
          then str
          else "class:${str}";
        mkRule = rule: (map (match: "${rule}, ${match}") (map getName config.wayland.shared.workspace_rules.${rule}));
        mkWsRule = rule: (map (match: "workspace ${rule}, ${match}") (map getName config.wayland.shared.workspace_rules."ws_${rule}"));
      in
        [
          "opacity 1.0 1.0, floating:1"
        ]
        ++ (lib.fold (a: b: a ++ b) [] (map mkRule ["float" "noblur" "noborder" "noshadow" "pin"]))
        ++ (lib.fold (a: b: a ++ b) [] (map mkWsRule (map toString (lib.range 1 5))));

      bindm = [
        "super,       mouse:272, movewindow"
        "super,       mouse:273, resizewindow"
      ];
      animations = {
        animation = [
          "workspaces, 1, 5, default, slidevert"
        ];
      };
      bind = let
        shared_binds = map ({
          mod ? "",
          exec,
          key,
        }: "${mod},${key},exec,${exec}")
        config.wayland.shared.bindexec;
        ws_binds = (
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "super,       code:1${toString i}, workspace,       ${toString ws}"
                "super SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
        );
      in
        [
          "super, h, movefocus, l"
          "super, l, movefocus, r"
          "super, k, workspace, e-1"
          "super, j, workspace, e+1"

          ",            keyboard_brightness_up_shortcut,   exec,          _tool_ctrl key up"
          ",            keyboard_brightness_down_shortcut, exec,          _tool_ctrl key down"

          "ALT,        F4, killactive,     "
          "super,       q,  exec,           hyprctl reload"

          "alt,        tab, exec, hyprswitch gui --mod-key alt_l --key tab --close mod-key-release --reverse-key=mod=shift && hyprswitch dispatch"
          "alt shift,  tab, exec, hyprswitch gui --mod-key alt_l --key tab --close mod-key-release --reverse-key=mod=shift && hyprswitch dispatch -r"

          "super,       grave, hyprexpo:expo, toggle"

          "super,       p,  pin,            "
          "super,       f,  fullscreen,     "
          "super shift, f,  togglefloating, "

          "super, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
          "super, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
          "super SHIFT, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "super SHIFT, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "super SHIFT, minus, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "super SHIFT, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "super SHIFT, 0, exec, hyprctl -q keyword cursor:zoom_factor 1"

          "super, m, togglespecialworkspace, magic"
          "super, m, movetoworkspace, +0"
          "super, m, togglespecialworkspace, magic"
          "super, m, movetoworkspace, special:magic"
          "super, m, togglespecialworkspace, magic"

          "super, D, exec, hyprdesk.sh"
          "super, A, exec, hypranim.sh"
        ]
        ++ shared_binds
        ++ ws_binds;
      bindel = map ({
        mod ? "",
        exec,
        key,
      }: "${mod},${key},exec,${exec}")
      config.wayland.shared.bindexec_el;

      binde = [
        "super, equal, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
        "super, minus, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
        "super, KP_ADD, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
        "super, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
      ];
    };

    extraConfig =
      /*
      hyprlang
      */
      ''

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

        bind = , r, exec,   bg.sh rand
        bind = , l, exec,   bg.sh last
        bind = , n, exec,   bg.sh next
        bind = , p, exec,   bg.sh prev

        bind = , g, submap,   gowall
        submap = gowall
        bind = , r, exec,   GO_WALL=nix bg.sh rand
        bind = , l, exec,   GO_WALL=nix bg.sh last
        bind = , n, exec,   GO_WALL=nix bg.sh next
        bind = , p, exec,   GO_WALL=nix bg.sh prev
        bind = , escape, submap, wallpaper

        bind = , i, submap, invert_gowall
        submap = invert_gowall
        bind = , r, exec,   GO_WALL_INVERT=1 GO_WALL=nix bg.sh rand
        bind = , l, exec,   GO_WALL_INVERT=1 GO_WALL=nix bg.sh last
        bind = , n, exec,   GO_WALL_INVERT=1 GO_WALL=nix bg.sh next
        bind = , p, exec,   GO_WALL_INVERT=1 GO_WALL=nix bg.sh prev
        bind = , escape, submap, gowall
        submap = gowall

        submap = wallpaper

        bind = , escape, submap, reset

        submap = reset

        windowrule = float, class:hyprpet
        windowrule = pin, class:hyprpet
        windowrule = noanim,class:hyprpet
        windowrule = nodim,class:hyprpet
        windowrule = noblur, class:hyprpet
        windowrule = nofocus, class:hyprpet
        windowrule = noshadow, class:hyprpet
        windowrule = noborder, class:hyprpet

      ''
      # windowrule=opacity 0.0 0.0,class:hyprpet
      + (
        if footalttab
        then ''
          exec-once = foot --server

          bind = ALT, tab, exec, hyprctl -q keyword animations:enabled false ; hyprctl -q dispatch exec "footclient -a alttab hypralttab.sh" ; hyprctl -q keyword unbind "ALT, TAB" ; hyprctl -q dispatch submap alttab

          submap=alttab
          bind = ALT, tab, sendshortcut, , tab, class:alttab
          bind = ALT SHIFT, tab, sendshortcut, shift, tab, class:alttab

          bindrt = ALT, ALT_L, exec, hyprdisable.sh ; hyprctl -q dispatch sendshortcut ,return,class:alttab
          bind = ALT, escape, exec, hyprdisable.sh ; hyprctl -q dispatch sendshortcut ,escape,class:alttab
          submap = reset

          workspace = special:alttab, gapsout:0, gapsin:0, bordersize:0
          windowrule = noanim, class:alttab
          windowrule = stayfocused, class:alttab
          windowrule = workspace special:alttab, class:alttab
          windowrule = bordersize 0, class:alttab


        ''
        else ""
      );
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "lock.sh";
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "lock.sh";
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1800; # 30min
          on-timeout = "systemctl suspend";
        }
        {
          timeout = 150; # 2.5min.
          on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "brightnessctl -r"; # monitor backlight restore.
        }
        {
          timeout = 150; # 2.5min.
          on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # turn off keyboard backlight.
          on-resume = "brightnessctl -rd rgb:kbd_backlight"; # turn on keyboard backlight.
        }
      ];
    };
  };
}
