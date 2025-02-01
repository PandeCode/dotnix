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

    options.sway.enable = lib.mkEnableOption "enable sway";

    config = lib.mkIf cfg.enable {
      wayland.enable = true;
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
              xkb_options = "ctrl:nocaps";
            };
          };
          window.titlebar = false;
          modifier = "Mod4";
          terminal = "wezterm";
          keybindings =
            flattenListAttrsToAttr
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
    };
  }
