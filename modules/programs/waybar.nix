{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.waybar;
in {
  options.waybar = {
    enable = lib.mkEnableOption "enable waybar";
    hyprland = lib.mkEnableOption "enable waybar for hyprland";
    # dwl = lib.mkEnableOption "enable waybar for dwl";
    # swayfx = lib.mkEnableOption "enable waybar for swayfx";
    # sway = lib.mkEnableOption "enable waybar for sway";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      style =
        /*
        css
        */
        ''
          /* @import url('../../.cache/wal/colors-waybar.css'); */

            * {
                font-size:15px;
                font-family: "CodeNewRoman Nerd Font Propo";
            }
            window#waybar{
                all:unset;
            }
            .modules-left {
                padding:7px;
                margin:5px;
                border-radius:10px;
                background: alpha(@background,.5);
                box-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
            }
            .modules-center {
                padding:7px;
                margin:5px;
                border-radius:10px;
                background: alpha(@background,.5);
                box-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
            }
            .modules-right {
                padding:7px;
                margin:5px;
                border-radius:10px;
                background: alpha(@background,.5);
                box-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
            }
            tooltip {
                background:@background;
                color: @color7;
            }
            #clock:hover, #custom-pacman:hover, #custom-notification:hover,#bluetooth:hover,#network:hover,#battery:hover, #cpu:hover,#memory:hover,#temperature:hover{
                transition: all .3s ease;
                color:@color9;
            }
            #custom-notification {
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;
            }
            #clock{
                padding: 0px 5px;
                color:@color7;
                transition: all .3s ease;
            }
            #custom-pacman{
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;

            }
            #workspaces {
                padding: 0px 5px;
            }
            #workspaces button {
                all:unset;
                padding: 0px 5px;
                color: alpha(@color9,.4);
                transition: all .2s ease;
            }
            #workspaces button:hover {
                color:rgba(0,0,0,0);
                border: none;
                text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .5);
                transition: all 1s ease;
            }
            #workspaces button.active {
                color: @color9;
                border: none;
                text-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
            }
            #workspaces button.empty {
                color: rgba(0,0,0,0);
                border: none;
                text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .2);
            }
            #workspaces button.empty:hover {
                color: rgba(0,0,0,0);
                border: none;
                text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .5);
                transition: all 1s ease;
            }
            #workspaces button.empty.active {
                color: @color9;
                border: none;
                text-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
            }
            #bluetooth{
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;

            }
            #network{
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;

            }
            #battery{
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;


            }
            #battery.charging {
                color: #26A65B;
            }

            #battery.warning:not(.charging) {
                color: #ffbe61;
            }

            #battery.critical:not(.charging) {
                color: #f53c3c;
                animation-name: blink;
                animation-duration: 0.5s;
                animation-timing-function: linear;
                animation-iteration-count: infinite;
                animation-direction: alternate;
            }
            #group-expand{
                padding: 0px 5px;
                transition: all .3s ease;
            }
            #custom-expand{
                padding: 0px 5px;
                color:alpha(@foreground,.2);
                text-shadow: 0px 0px 2px rgba(0, 0, 0, .7);
                transition: all .3s ease;
            }
            #custom-expand:hover{
                color:rgba(255,255,255,.2);
                text-shadow: 0px 0px 2px rgba(255, 255, 255, .5);
            }
            #custom-colorpicker{
                padding: 0px 5px;
            }
            #cpu,#memory,#temperature{
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;

            }
            #custom-endpoint{
                color:transparent;
                text-shadow: 0px 0px 1.5px rgba(0, 0, 0, 1);

            }
            #tray{
                padding: 0px 5px;
                transition: all .3s ease;

            }
            #tray menu * {
                padding: 0px 5px;
                transition: all .3s ease;
            }

            #tray menu separator {
                padding: 0px 5px;
                transition: all .3s ease;
            }
        '';
      settings = [
        {
          layer = "top";
          position = "top";
          reload_style_on_change = true;
          modules-left = ["custom/notification" "clock" "custom/pacman" "tray"];
          modules-center = ["hyprland/workspaces"];
          modules-right = ["group/expand" "bluetooth" "network" "battery"];

          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              active = "";
              default = "";
              empty = "";
            };
            persistent-workspaces = {
              "*" = [1 2 3 4 5];
            };
          };

          "custom/notification" = {
            tooltip = false;
            format = "";
            on-click = "swaync-client -t -sw";
            escape = true;
          };

          clock = {
            format = "{:%I:%M:%S %p} ";
            interval = 1;
            tooltip-format = "<tt>{calendar}</tt>";
            calendar = {
              format = {
                today = "<span color='#fAfBfC'><b>{}</b></span>";
              };
            };
            actions = {
              "on-click-right" = "shift_down";
              "on-click" = "shift_up";
            };
          };

          network = {
            format-wifi = "";
            format-ethernet = "";
            format-disconnected = "";
            tooltip-format-disconnected = "Error";
            tooltip-format-wifi = "{essid} ({signalStrength}%) ";
            tooltip-format-ethernet = "{ifname} 🖧 ";
            on-click = "kitty nmtui";
          };

          bluetooth = {
            format-on = "󰂯";
            format-off = "BT-off";
            format-disabled = "󰂲";
            format-connected-battery = "{device_battery_percentage}% 󰂯";
            format-alt = "{device_alias} 󰂯";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\n{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\n{device_address}\n{device_battery_percentage}%";
            on-click-right = "blueman-manager";
          };

          battery = {
            interval = 30;
            states = {
              good = 95;
              warning = 30;
              critical = 20;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% 󰂄";
            format-plugged = "{capacity}% 󰂄 ";
            format-alt = "{time} {icon}";
            format-icons = ["󰁻" "󰁼" "󰁾" "󰂀" "󰂂" "󰁹"];
          };

          "custom/pacman" = {
            format = "󰅢 {}";
            interval = 30;
            exec = "checkupdates | wc -l";
            exec-if = "exit 0";
            on-click = "wezterm sh -c 'yay; sudo pacman -Syu; echo Done - Press enter to exit; read'; pkill -SIGRTMIN+8 waybar";
            signal = 8;
            tooltip = false;
          };

          "custom/expand" = {
            format = "";
            tooltip = false;
          };

          "custom/endpoint" = {
            format = "|";
            tooltip = false;
          };

          "group/expand" = {
            orientation = "horizontal";
            drawer = {
              transition-duration = 600;
              transition-to-left = true;
              click-to-reveal = true;
            };
            modules = ["custom/expand" "custom/colorpicker" "cpu" "memory" "temperature" "custom/endpoint"];
          };

          "custom/colorpicker" = {
            format = "{}";
            return-type = "json";
            interval = "once";
            exec = "~/.config/waybar/scripts/colorpicker.sh -j";
            on-click = "~/.config/waybar/scripts/colorpicker.sh";
            signal = 1;
          };

          cpu = {
            format = "󰻠";
            tooltip = true;
          };

          memory = {
            format = "";
          };

          temperature = {
            critical-threshold = 80;
            format = "";
          };

          tray = {
            icon-size = 14;
            spacing = 10;
          };
        }

        # {
        #   layer = "top";
        #   position = "top";
        #   mod = "dock";
        #   exclusive = true;
        #   passtrough = false;
        #   gtk-layer-shell = true;
        #   height = 0;
        #
        #   # waybars-left = ["hyprland/workspaces" "hyprland/submap" "wlr/taskbar"];
        #   # waybars-right = ["mpd" "clock" "temperature"];
        #   modules-left = [
        #     "hyprland/workspaces"
        #     "custom/divider"
        #     "custom/weather"
        #     "custom/divider"
        #     "cpu"
        #     "custom/divider"
        #     "memory"
        #   ];
        #   modules-center = ["hyprland/window"];
        #   modules-right = [
        #     "tray"
        #     "network"
        #     "custom/divider"
        #     "backlight"
        #     "custom/divider"
        #     "pulseaudio"
        #     "custom/divider"
        #     "battery"
        #     "custom/divider"
        #     "clock"
        #   ];
        #   "hyprland/window" = {format = "{}";};
        #   "wlr/workspaces" = {
        #     on-scroll-up = "hyprctl dispatch workspace e+1";
        #     on-scroll-down = "hyprctl dispatch workspace e-1";
        #     all-outputs = true;
        #     on-click = "activate";
        #   };
        #   battery = {
        #     format = "{capacity}% {icon}";
        #     format-icons = ["" "" "" "" ""];
        #   };
        #   cpu = {
        #     interval = 10;
        #     format = "󰻠 {}%";
        #     max-length = 10;
        #     on-click = "";
        #   };
        #   memory = {
        #     interval = 30;
        #     format = "  {}%";
        #     format-alt = " {used:0.1f}G";
        #     max-length = 10;
        #   };
        #   backlight = {
        #     format = "󰖨 {}";
        #     device = "acpi_video0";
        #   };
        #   "custom/weather" = {
        #     tooltip = true;
        #     format = "{}";
        #     restart-interval = 300;
        #     exec = "/home/roastbeefer/.cargo/bin/weather";
        #   };
        #   tray = {
        #     icon-size = 13;
        #     tooltip = false;
        #     spacing = 10;
        #   };
        #   network = {
        #     format = "󰖩 {essid}";
        #     format-disconnected = "󰖪 disconnected";
        #   };
        #   clock = {
        #     format = " {:%I:%M %p   %m/%d} ";
        #     tooltip-format = ''
        #       <big>{:%Y %B}</big>
        #       <tt><small>{calendar}</small></tt>'';
        #   };
        #   pulseaudio = {
        #     format = "{icon} {volume}%";
        #     tooltip = false;
        #     format-muted = " Muted";
        #     on-click = "pamixer -t";
        #     on-scroll-up = "pamixer -i 5";
        #     on-scroll-down = "pamixer -d 5";
        #     scroll-step = 5;
        #     format-icons = {
        #       headphone = "";
        #       hands-free = "";
        #       headset = "";
        #       phone = "";
        #       portable = "";
        #       car = "";
        #       default = ["" "" ""];
        #     };
        #   };
        #   "pulseaudio#microphone" = {
        #     format = "{format_source}";
        #     tooltip = false;
        #     format-source = " {volume}%";
        #     format-source-muted = " Muted";
        #     on-click = "pamixer --default-source -t";
        #     on-scroll-up = "pamixer --default-source -i 5";
        #     on-scroll-down = "pamixer --default-source -d 5";
        #     scroll-step = 5;
        #   };
        #   "custom/divider" = {
        #     format = " | ";
        #     interval = "once";
        #     tooltip = false;
        #   };
        #   "custom/endright" = {
        #     format = "_";
        #     interval = "once";
        #     tooltip = false;
        #   };
        # }
      ];
    };
  };
}
