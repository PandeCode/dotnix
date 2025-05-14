{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.sway;
  # [ { a = "a"; } { b = "b"; } { c = "c"; } ] -> { a = "a"; b = "b"; c = "c"; }
  flattenListAttrsToAttr = lib.foldl' (a: b: a // b) {};
in
  with builtins;
  with lib; {
    imports = [
      ../wayland/home.nix
    ];

    #     	wayland.windowManager.sway.config.bars = [
    # ({
    #   mode = "dock";
    #   hiddenState = "hide";
    #   position = "top";
    #   workspaceButtons = true;
    #   workspaceNumbers = false;
    #   statusCommand = "${pkgs.i3status}/bin/i3status";
    #   trayOutput = "primary";
    # } // config.lib.stylix.sway.bar)
    # ];
    wayland.windowManager.sway = {
      enable = true;

      # package = pkgs.swayfx;

      wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
      extraConfig = ''
        # input type:keyboard {
        # 	  xkb_options ctrl:nocaps
        # }
      '';
      config = rec {
        input = {
          "type:keyboard" = {
            xkb_options = "ctrl:nocaps,grp:win_space_toggle";
            xkb_layout = "us,es";
          };
          # kb_layout = "us,es";
          # kb_options = "grp:win_space_toggle";
        };
        window.titlebar = false;
        modifier = "Mod4";
        terminal = config.wayland.shared.terminal;
        keybindings = let
          alt = "Mod1";
          super = "Mod4";
        in
          {
            "Mod1+f4" = "killactive";
          }
          // flattenListAttrsToAttr
          ((genList (
                j: let
                  i = toString (j + 1);
                in {
                  "super+${i}" = "workspace number ${i}";
                  "super+shift+${i}" = "move container to workspace number ${i}";
                }
              )
              9)
            ++ (map ({
                mod,
                key,
                exec,
              }: {
                "${(replaceStrings [" "] ["+"] (trim "${mod} ${key}"))}" = "exec ${exec}";
              })
              (config.wayland.shared.bindexec ++ config.wayland.shared.bindexec_el)));
        startup =
          map (command: {inherit command;}) config.wayland.shared.startup;
      };
    };
  }
