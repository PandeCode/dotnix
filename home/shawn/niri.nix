# my niri settings, ported from old/modules/wm/niri/home.nix (c0d426a).
# startup, command binds and floating windows come from wm.nix
{ lib, pkgs, ... }:

let
  flat = {
    accel-speed = 0.2;
    accel-profile = "flat";
  };

  easing = {
    duration-ms = 250;
    curve = "linear";
  };

  onDisplay = x: y: corner: {
    default-floating-position._props = {
      inherit x y;
      relative-to = corner;
    };
  };
in

{
  home.packages = [ pkgs.nirius ];

  dotnix.niri = {
    enable = true;

    startup = [
      "niriusd"
      "awww-daemon -n backdrop"
    ];

    shaders = {
      open = ../../config/niri/shaders/open.glsl;
      close = ../../config/niri/shaders/close.glsl;
      resize = ../../config/niri/shaders/resize.glsl;
    };

    windowRules = [
      (
        {
          match._props = {
            app-id = "steam";
            title = "^notificationtoasts_\\d+_desktop$";
          };
        }
        // onDisplay 10 10 "bottom-right"
      )
      (
        {
          _children = map (m: { match._props = m; }) [
            { title = "Picture-in-Picture"; }
            { app-id = "feh"; }
            { app-id = "pqiv"; }
            { app-id = "Pqiv"; }
            { app-id = "nsxiv"; }
          ];
        }
        // onDisplay 10 10 "top-right"
      )
      {
        _children =
          map
            (app-id: {
              match._props = {
                inherit app-id;
                at-startup = true;
              };
            })
            [
              "com.mitchellh.ghostty"
              "^zen-twilight$"
            ];
        open-maximized = true;
      }
      {
        match._props.app-id = "^zen-twilight$";
        variable-refresh-rate = true;
        border.width = 0;
      }
    ];

    layerRules = [
      {
        match._props.namespace = "backdrop";
        place-within-backdrop = true;
      }
      {
        match._props.namespace = "rofi";
        opacity = 0.9;
      }
    ];

    settings = {
      hotkey-overlay.skip-at-startup = { };
      prefer-no-csd = { };

      layout.border.width = 1;

      output = {
        _args = [ "eDP-1" ];
        mode = "1920x1200@165.000";
        scale = 1;
        variable-refresh-rate._props.on-demand = true;
      };

      input = {
        mouse = flat;

        keyboard.xkb.options = "grp:win_space_toggle,ctrl:nocaps";

        touchpad = flat // {
          tap = { };
          natural-scroll = { };
          scroll-method = "two-finger";
          disabled-on-external-mouse = { };
        };
      };

      switch-events = {
        tablet-mode-on.spawn = [
          "gsettings"
          "set"
          "org.gnome.desktop.a11y.applications"
          "screen-keyboard-enabled"
          "true"
        ];
        tablet-mode-off.spawn = [
          "gsettings"
          "set"
          "org.gnome.desktop.a11y.applications"
          "screen-keyboard-enabled"
          "false"
        ];
      };

      animations = {
        window-open = easing;
        window-close = easing;
        window-resize = easing;
      };

      binds =
        lib.attrsets.listToAttrs (
          map (n: {
            name = "Mod+${toString n}";
            value.focus-workspace = n;
          }) (lib.lists.range 1 9)
        )
        // {
          "Super+Alt+H".focus-monitor-left = { };
          "Super+Alt+J".focus-monitor-down = { };
          "Super+Alt+K".focus-monitor-up = { };
          "Super+Alt+L".focus-monitor-right = { };

          "Super+Shift+Alt+H".move-column-to-monitor-left = { };
          "Super+Shift+Alt+J".move-column-to-monitor-down = { };
          "Super+Shift+Alt+K".move-column-to-monitor-up = { };
          "Super+Shift+Alt+L".move-column-to-monitor-right = { };

          "Super+h".focus-column-left = { };
          "Super+l".focus-column-right = { };
          "Super+j".focus-window-or-workspace-down = { };
          "Super+k".focus-window-or-workspace-up = { };

          "Super+Shift+h".consume-or-expel-window-left = { };
          "Super+Shift+l".consume-or-expel-window-right = { };

          "Super+Shift+j".move-window-to-workspace-down._props.focus = true;
          "Super+Shift+k".move-window-to-workspace-up._props.focus = true;

          "Super+Ctrl+l".set-column-width = "+10%";
          "Super+Ctrl+h".set-column-width = "-10%";

          "Super+Space".expand-column-to-available-width = { };
          "Super+Shift+Space".maximize-column = { };

          "Super+f" = {
            _props.repeat = false;
            fullscreen-window = { };
          };
          "Super+Alt+f" = {
            _props.repeat = false;
            toggle-windowed-fullscreen = { };
          };
          "Super+Shift+f" = {
            _props.repeat = false;
            toggle-window-floating = { };
          };

          "Super+Shift+q".quit._props.skip-confirmation = true;

          "Super+Tab".toggle-overview = { };
          "Alt+f4".close-window = { };

          "Super+Print".screenshot-screen._props.show-pointer = false;
          "Super+Shift+Print".screenshot._props.show-pointer = false;
          "Super+a".spawn = [
            "nirius"
            "toggle-follow-mode"
          ];
        };
    };
  };
}
