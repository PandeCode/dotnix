{
  lib,
  config,
  ...
}: let
  shared = config.wayland.shared;
  splitBySpace = v: builtins.filter builtins.isString (builtins.split "[ ]+" v);

  utils = {
    rgb = r: g: b: {
      inherit r g b;
      a = 1.0;
    };

    rgba = r: g: b: a: {inherit r g b a;};

    # NOTE enums will be special in my json2zon
    left = ".left";
    right = ".right";
    never = ".never";
    always = ".always";
    single = ".single";

    ## in types.zig
    resize_window = ".resize_window";
    move_window = ".move_window";

    close_window = ".close_window";
    toggle_fullscreen = ".toggle_fullscreen";
    toggle_maximize_column = ".toggle_maximize_column";
    toggle_passthrough = ".toggle_passthrough";
    adjust_window_width = ".adjust_window_width";
    set_window_width = ".set_window_width";
    focus_window_left = ".focus_window_left";
    focus_window_or_output_left = ".focus_window_or_output_left";
    focus_window_right = ".focus_window_right";
    focus_window_or_output_right = ".focus_window_or_output_right";
    move_window_left = ".move_window_left";
    move_window_right = ".move_window_right";
    move_window_left_or_to_output_left = ".move_window_left_or_to_output_left";
    move_window_right_or_to_output_right = ".move_window_right_or_to_output_right";
    toggle_workspace_floating = ".toggle_workspace_floating";
    focus_workspace_above = ".focus_workspace_above";
    focus_workspace_below = ".focus_workspace_below";
    focus_workspace_or_output_above = ".focus_workspace_or_output_above";
    focus_workspace_or_output_below = ".focus_workspace_or_output_below";
    focus_workspace_previous = ".focus_workspace_previous";
    focus_workspace_number = ".focus_workspace_number";
    move_window_to_workspace_above = ".move_window_to_workspace_above";
    move_window_to_workspace_below = ".move_window_to_workspace_below";
    move_window_to_workspace_or_output_above = ".move_window_to_workspace_or_output_above";
    move_window_to_workspace_or_output_below = ".move_window_to_workspace_or_output_below";
    move_window_to_workspace_number = ".move_window_to_workspace_number";
    send_window_to_workspace_above = ".send_window_to_workspace_above";
    send_window_to_workspace_below = ".send_window_to_workspace_below";
    send_window_to_workspace_or_output_above = ".send_window_to_workspace_or_output_above";
    send_window_to_workspace_or_output_below = ".send_window_to_workspace_or_output_below";
    send_window_to_workspace_number = ".send_window_to_workspace_number";
    focus_output_left = ".focus_output_left";
    focus_output_right = ".focus_output_right";
    focus_output_above = ".focus_output_above";
    focus_output_below = ".focus_output_below";
    move_window_to_output_left = ".move_window_to_output_left";
    move_window_to_output_right = ".move_window_to_output_right";
    move_window_to_output_above = ".move_window_to_output_above";
    move_window_to_output_below = ".move_window_to_output_below";
    send_window_to_output_left = ".send_window_to_output_left";
    send_window_to_output_right = ".send_window_to_output_right";
    send_window_to_output_above = ".send_window_to_output_above";
    send_window_to_output_below = ".send_window_to_output_below";
    exit = ".exit";
    reload_config = ".reload_config";
  };
in
  with utils; {
    vertical_gap = 9; # Gap between windows and the output's top/bottom edge
    horizontal_gap = 9; # Gap between adjacent windows
    default_window_width = 0.5; # Default proportion of the output's available width that a window occupies when spawned

    # Center the focused window (never; always; single)
    # Set it to single to center a window if it's the only window in the workspace
    center_focused_window = always;

    no_csd = true; # Disable client side decorations
    animation_duration = 200; # Duration of animations; in milliseconds
    dynamic_workspaces = true; # Enable dynamic workspaces

    border = {
      width = 3;
      focused_color = rgb 141 214 0;
      unfocused_color = rgb 160 160 160;
    };

    # Theme and size of cursor (set it to null to use default cursor)
    #cursor ={theme = "Adwaita";size = 24;};
    cursor = null;

    spawn_at_startup =
      [["notify-send" "kazuha" "Welcome to rill"]]
      ++ (map splitBySpace shared.startup);

    pointer_bindings = [
      # Button: left; right; middle
      {
        button = left;
        modifiers = {mod4 = true;};
        action = move_window;
      }
      {
        button = right;
        modifiers = {mod4 = true;};
        action = resize_window;
      }
    ];

    keybindings = let
      strModToRillMod = key: let
        c = str: attr:
          if lib.hasInfix str (lib.toLower key)
          then attr
          else {};
      in
        (c "shift" {shift = true;})
        // (c "alt" {mod1 = true;})
        // (c "super" {mod4 = true;})
        // (c "ctrl" {ctrl = true;});

      mkBinding = binding: action: {};
    in
      (
        map
        (
          v: {
            inherit (v) key;
            action = {spawn = splitBySpace v.exec;};
            modifiers = strModToRillMod v.mod;
          }
        )
        (shared.bindexec
          ++ shared.bindexec_el)
      )
      ++ (
        builtins.concatMap
        (
          n: [
            {
              key = toString n;
              modifiers = {mod4 = true;};
              action = {focus_workspace_number = n;};
            }
            {
              key = toString n;
              modifiers = {
                mod4 = true;
                shift = true;
              };
              action = {move_window_to_workspace_number = n;};
            }
          ]
        )
        (builtins.genList (x: x + 1) 9)
      )
      ++ [
      ]
      ++ [
        # Key: keysym names (case insensitive) from xkbcommon-keysyms.h
        # Common ones include:
        # "Left"; "Up"; "Right"; "Down"; "BackSpace"; "Tab"; "Space"; "Return"; "Escape"; "Delete";
        # "XF86MonBrightnessUp"; "XF86MonBrightnessDown";
        # "XF86AudioRaiseVolume"; "XF86AudioLowerVolume"; "XF86AudioMute"; "XF86AudioMicMute"
        #
        # Modifiers: shift; ctrl; mod1 (alt); mod4 (super)

        {
          key = "F4";
          modifiers = {mod1 = true;};
          action = close_window;
        }
        {
          key = "f";
          modifiers = {mod4 = true;};
          action = toggle_fullscreen;
        }
        {
          key = "F11";
          modifiers = {mod4 = true;};
          action = toggle_passthrough;
        }
        {
          key = "f";
          modifiers = {
            shift = true;
            mod4 = true;
          };
          action = toggle_workspace_floating;
        }

        # Decrease focused window's width by 0.1 of the output's available width
        {
          key = "minus";
          modifiers = {mod4 = true;};
          action = {adjust_window_width = -0.1;};
        }
        # Increase focused window's width by 0.1 of the output's available width
        {
          key = "equal";
          modifiers = {mod4 = true;};
          action = {adjust_window_width = 0.1;};
        }
        # Set focused window's width to 0.5 of the output's available width
        {
          key = "BackSpace";
          modifiers = {mod4 = true;};
          action = {set_window_width = 0.5;};
        }

        {
          key = "h";
          modifiers = {mod4 = true;};
          action = focus_window_left;
        }
        {
          key = "l";
          modifiers = {mod4 = true;};
          action = focus_window_right;
        }
        {
          key = "h";
          modifiers = {
            mod4 = true;
            shift = true;
          };
          action = move_window_left;
        }
        {
          key = "l";
          modifiers = {
            mod4 = true;
            shift = true;
          };
          action = move_window_right;
        }

        {
          key = "k";
          modifiers = {mod4 = true;};
          action = focus_workspace_above;
        }
        {
          key = "j";
          modifiers = {mod4 = true;};
          action = focus_workspace_below;
        }
        {
          key = "grave";
          modifiers = {mod4 = true;};
          action = focus_workspace_previous;
        }

        {
          key = "k";
          modifiers = {
            mod4 = true;
            shift = true;
          };
          action = move_window_to_workspace_above;
        }
        {
          key = "j";
          modifiers = {
            mod4 = true;
            shift = true;
          };
          action = move_window_to_workspace_below;
        }

        # {
        #   key = "h";
        #   modifiers = {mod4 = true;};
        #   action = focus_output_left;
        # }
        # {
        #   key = "l";
        #   modifiers = {mod4 = true;};
        #   action = focus_output_right;
        # }
        # {
        #   key = "k";
        #   modifiers = {mod4 = true;};
        #   action = focus_output_above;
        # }
        #
        # {
        #   key = "j";
        #   modifiers = {mod4 = true;};
        #   action = focus_output_below;
        # }
        #
        # {
        #   key = "h";
        #   modifiers = {
        #     mod4 = true;
        #     shift = true;
        #   };
        #   action = move_window_to_output_left;
        # }
        # {
        #   key = "l";
        #   modifiers = {
        #     mod4 = true;
        #     shift = true;
        #   };
        #   action = move_window_to_output_right;
        # }
        # {
        #   key = "k";
        #   modifiers = {
        #     mod4 = true;
        #     shift = true;
        #   };
        #   action = move_window_to_output_above;
        # }
        # {
        #   key = "j";
        #   modifiers = {
        #     mod4 = true;
        #     shift = true;
        #   };
        #   action = move_window_to_output_below;
        # }

        {
          key = "Escape";
          modifiers = {mod4 = true;};
          action = exit;
        }
        {
          key = "r";
          modifiers = {mod4 = true;};
          action = reload_config;
        }
      ];
  }
