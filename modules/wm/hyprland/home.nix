{
  pkgs,
  config,
  lib,
  inputs,
  sharedConfig,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  footalttab = true;
in {
  imports = [
    inputs.hyprland.homeManagerModules.default
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

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;

    plugins = with inputs.hyprland-plugins.packages.${system}; [
      inputs.hypr-dynamic-cursors.packages.${system}.hypr-dynamic-cursors
      hyprexpo
      hyprwinwrap
      hyprscrolling
    ];

    settings = {
      env = ["AQ_DRM_DEVICES,/dev/dri/card2:/dev/dri/card1"];

      decoration = {
        dim_inactive = true;
        rounding = 8;
      };

      general = {
        gaps_out = 8;
        layout = "scrolling";
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
        hyprscrolling = {
          fullscreen_on_one_column = "true";
          column_width = 0.5;
          explicit_column_widths = "0.333, 0.5, 0.667, 1.0";
        };
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

      animations = {
        animation = [
          "workspaces,                         1,           5,    default,   slidevert"
          "windows,                            1,           4,    default,   slide"
          "windowsIn,                          1,           4,    default,   slide"
          "windowsOut,                         1,           4,    default,   slide"
        ];
      };

      exec-once =
        config.wayland.shared.startup
        ++ [
          "waybar"
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
          "suppressevent maximize, class:.*"
        ]
        ++ (lib.fold (a: b: a ++ b) [] (map mkRule ["float" "noblur" "noborder" "noshadow" "pin"]))
        ++ (lib.fold (a: b: a ++ b) [] (map mkWsRule (map toString (lib.range 1 5))));

      bindm = [
        "super,       mouse:272, movewindow"
        "super,       mouse:273, resizewindow"
      ];

      bind = let
      in
        [
          "super, h, exec, hyprctl.sh focus_l"
          "super, l, exec, hyprctl.sh focus_r"
          "super, j, exec, hyprctl.sh focus_d"
          "super, k, exec, hyprctl.sh focus_u"

          "super shift, h, exec, hyprctl.sh move_l"
          "super shift, l, exec, hyprctl.sh move_r"
          "super shift, j, exec, hyprctl.sh move_d"
          "super shift, k, exec, hyprctl.sh move_u"

          "super ctrl, h, exec, hyprctl.sh resize_l"
          "super ctrl, l, exec, hyprctl.sh resize_r"
          "super ctrl, j, exec, hyprctl.sh resize_d"
          "super ctrl, k, exec, hyprctl.sh resize_u"

          "super, D, exec, hyprdesk.sh"
          "super, A, exec, hypranim.sh"
          "super,       q,  exec,           hyprctl reload"

          "ALT,        F4, killactive,     "

          ",            keyboard_brightness_up_shortcut,   exec,          _tool_ctrl key up"
          ",            keyboard_brightness_down_shortcut, exec,          _tool_ctrl key down"

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
        ]
        ++ (
          map ({
            mod ? "",
            exec,
            key,
          }: "${mod},${key},exec,${exec}")
          config.wayland.shared.bindexec
        )
        ++ (
          builtins.concatLists (builtins.genList (
              i: [
                "super,       code:1${toString i}, workspace,       ${toString (i + 1)}"
                "super SHIFT, code:1${toString i}, movetoworkspace, ${toString (i + 1)}"
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

      binde = [
        "super,                              equal,       exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
        "super,                              minus,       exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
        "super,                              KP_ADD,      exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
        "super,                              KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
      ];
    };

    # col.active_border = rgba(0,            190,         150,  1) rgba(0, 0, 0, 0) rgba(100, 190, 255, 1) rgba(0, 0, 0, 0) rgba (0, 190, 150, 1) 35deg
    extraConfig = let
      pipW = 480;
      sW = 1920;
    in
      /*
      hyprlang
      */
      ''
        windowrule = animation slide top,    class:^(obol_slide_top)$
        windowrule = animation slide bottom, class:^(obol_slide_bottom)$
        windowrule = animation slide left,   class:^(obol_slide_left)$
        windowrule = animation slide right,  class:^(obol_slide_right)$

        windowrule = noanim,   title:GlslViewer
        windowrule = noblur,   title:GlslViewer
        windowrule = nodim,    title:GlslViewer
        windowrule = float,    title:GlslViewer
        windowrule = pin,      title:GlslViewer

        windowrule = float,    class:raypets
        windowrule = pin,      class:raypets
        windowrule = noanim,   class:raypets
        windowrule = nodim,    class:raypets
        windowrule = noblur,   class:raypets
        windowrule = nofocus,  class:raypets
        windowrule = noshadow, class:raypets
        windowrule = noborder, class:raypets

        windowrule = float,    class:deskpet
        windowrule = pin,      class:deskpet
        windowrule = noanim,   class:deskpet
        windowrule = nodim,    class:deskpet
        windowrule = noblur,   class:deskpet
        windowrule = nofocus,  class:deskpet
        windowrule = noshadow, class:deskpet
        windowrule = noborder, class:deskpet

        windowrule = size ${toString pipW} ${toString ((pipW * 9) / 16)}, title:^(Picture-in-Picture)$
        windowrule = move ${toString (sW - 20 - pipW)} 50,                title:^(Picture-in-Picture)$
        windowrule = workspace 1 silent,                                  title:^(Picture-in-Picture)$
        windowrule = float,                                               title:^(Picture-in-Picture)$
        windowrule = pin,                                                 title:^(Picture-in-Picture)$
        windowrule = opacity 1.0 override 1.0 override,                   title:^(Picture-in-Picture)$
        windowrule = noblur,                                              title:^(Picture-in-Picture)$
        windowrule = nodim,                                               title:^(Picture-in-Picture)$
        windowrule = noshadow,                                            title:^(Picture-in-Picture)$
        windowrule = noborder,                                            title:^(Picture-in-Picture)$

        windowrule = float,                             class:^(mpv)$
        windowrule = pin,                               class:^(mpv)$
        windowrule = size 320 180,                      class:^(mpv)$
        windowrule = move 20 20,                        class:^(mpv)$
        windowrule = opacity 1.0 override 1.0 override, class:^(mpv)$
        windowrule = noblur,                            class:^(mpv)$
        windowrule = nodim,                             class:^(mpv)$

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
      ''
      # windowrule=opacity 0.0 0.0,class:deskpet
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
}
