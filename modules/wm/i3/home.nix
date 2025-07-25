{
  pkgs,
  lib,
  config,
  utils,
  ...
}:
with builtins;
with utils;
with lib; let
  flattenListAttrsToAttr = lib.foldl' (a: b: a // b) {};
  _ = {
    mod,
    key,
    exec,
  }: {
    "${(replaceStrings [" " "super" "alt"] ["+" "Mod4" "Mod1"] (trim "${mod} ${key}"))}" = "exec ${exec}";
  };
  mapBindingsToi3 = map _;
  c = config.lib.stylix.colors;
  font = config.stylix.fonts.sansSerif.name;
in {
  imports = [
    ../x/home.nix
  ];

  programs.i3status-rust = {
    enable = true;
    bars.default = {
      theme = "solarized-dark";
      icons = "awesome4";
      blocks =
        (map (i: i // {block = "custom";}) [
          {
            command = "lyrics-line.sh";
            interval = 3;
          }
          {
            command = "curl -Ss 'https://wttr.in?0&T&Q' | cut -c 16- | head -2 | xargs echo";
            interval = 3600;
          }
          {
            command = "xtitle -s";
            interval = 1;
          }
        ])
        ++ [
          {
            alert = 10.0;
            block = "disk_space";
            info_type = "available";
            interval = 60;
            path = "/";
            warning = 20.0;
          }
          {
            block = "memory";
            format = " $icon $mem_used_percents ";
            format_alt = " $icon $swap_used_percents ";
          }
          {
            block = "cpu";
            interval = 1;
          }
          {
            block = "load";
            format = " $icon $1m ";
            interval = 1;
          }
          {
            block = "sound";
          }
          {
            block = "time";
            format = " $timestamp.datetime(f:'%a %d/%m %R') ";
            interval = 60;
          }
        ];
    };
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    extraConfig = ''
      for_window [class="feh"] floating enable, sticky enable, border pixel 0, move absolute position 0 px 0 px
    '';
    config = {
      bars = [
        {
          mode = "dock";
          hiddenState = "hide";
          position = "top";
          workspaceButtons = true;
          workspaceNumbers = true;
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-i3.toml";
          fonts = {
            names = ["monospace"];
            size = 8.0;
          };
          trayOutput = "primary";
          # colors = {
          #   background = "#000000";
          #   statusline = "#ffffff";
          #   separator = "#666666";
          #   focusedWorkspace = {
          #     border = "#4c7899";
          #     background = "#285577";
          #     text = "#ffffff";
          #   };
          #   activeWorkspace = {
          #     border = "#333333";
          #     background = "#5f676a";
          #     text = "#ffffff";
          #   };
          #   inactiveWorkspace = {
          #     border = "#333333";
          #     background = "#222222";
          #     text = "#888888";
          #   };
          #   urgentWorkspace = {
          #     border = "#2f343a";
          #     background = "#900000";
          #     text = "#ffffff";
          #   };
          #   bindingMode = {
          #     border = "#2f343a";
          #     background = "#900000";
          #     text = "#ffffff";
          #   };
          # };
        }
      ];
      window.titlebar = false;
      modifier = "Mod4";
      inherit (config.shared.x) terminal;
      keybindings =
        {
          "Mod1+F4" = "kill";
          "Mod4+f" = "fullscreen toggle";
          "Mod4+Ctrl+f" = "fullscreen toggle";
          "Mod4+Shift+f" = "floating toggle";

          "Mod4+j" = "workspace next_on_output";
          "Mod4+k" = "workspace prev_on_output";

          "Mod4+l" = "focus left";
          "Mod4+h" = "focus right";

          "Mod4+Shift+j" = "move container to workspace next_on_output";
          "Mod4+Shift+k" = "move container to workspace prev_on_output";
        }
        // flattenListAttrsToAttr
        (
          (genList (
              j: let
                i = toString (j + 1);
              in {
                "Mod4+${i}" = "workspace number ${i}";
                "Mod4+shift+${i}" = "move container to workspace number ${i}";
              }
            )
            9)
          ++ (mapBindingsToi3 (config.x.shared.bindexec ++ config.x.shared.bindexec_el))
        );

      startup =
        map (command: {inherit command;}) (config.x.shared.startup ++ ["spatial"]);
    };
  };
}
