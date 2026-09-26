# my rill settings, ported from old/modules/wm/river/config.nix. startup
# and command binds come from wm.nix
{ lib, ... }:

let
  enum = name: { _enum = name; };

  rgb = r: g: b: {
    inherit r g b;
    a = 1.0;
  };

  super = {
    mod4 = true;
  };
  superShift = {
    mod4 = true;
    shift = true;
  };

  key = modifiers: key: action: { inherit key modifiers action; };
in

{
  dotnix.river = {
    enable = true;

    startup = [ "notify-send kazuha 'Welcome to rill'" ];

    settings = {
      vertical_gap = 9;
      horizontal_gap = 9;
      # share of the output's width a new window takes
      default_window_width = 0.5;
      # never, always, or single (only when it is the only window)
      center_focused_window = enum "always";
      no_csd = true;
      animation_duration = 200;
      dynamic_workspaces = true;

      border = {
        width = 3;
        focused_color = rgb 141 214 0;
        unfocused_color = rgb 160 160 160;
      };

      # null keeps the default cursor
      cursor = null;

      pointer_bindings = [
        {
          button = enum "left";
          modifiers = super;
          action = enum "move_window";
        }
        {
          button = enum "right";
          modifiers = super;
          action = enum "resize_window";
        }
      ];
    };

    # keys are xkbcommon keysym names; modifiers: shift, ctrl, mod1 (alt),
    # mod4 (super)
    keybindings =
      lib.lists.concatMap (n: [
        (key super (toString n) { focus_workspace_number = n; })
        (key superShift (toString n) { move_window_to_workspace_number = n; })
      ]) (lib.lists.range 1 9)
      ++ [
        (key { mod1 = true; } "F4" (enum "close_window"))
        (key super "f" (enum "toggle_fullscreen"))
        (key super "F11" (enum "toggle_passthrough"))
        (key superShift "f" (enum "toggle_workspace_floating"))

        (key super "minus" { adjust_window_width = -0.1; })
        (key super "equal" { adjust_window_width = 0.1; })
        (key super "BackSpace" { set_window_width = 0.5; })

        (key super "h" (enum "focus_window_left"))
        (key super "l" (enum "focus_window_right"))
        (key superShift "h" (enum "move_window_left"))
        (key superShift "l" (enum "move_window_right"))

        (key super "k" (enum "focus_workspace_above"))
        (key super "j" (enum "focus_workspace_below"))
        (key super "grave" (enum "focus_workspace_previous"))
        (key superShift "k" (enum "move_window_to_workspace_above"))
        (key superShift "j" (enum "move_window_to_workspace_below"))

        (key super "Escape" (enum "exit"))
        (key super "r" (enum "reload_config"))
      ];
  };
}
