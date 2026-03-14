{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    python3Packages.pygobject3
  ];

  programs.waybar = {
    enable = true;
    style = let
      font = config.stylix.fonts.sansSerif.name;
    in
      with config.lib.stylix.colors;
      #css
        ''
          @define-color foreground #${base04};
          @define-color background #${base01};
          @define-color cursor #${base04};

          @define-color color0 #${base00}; @define-color color1 #${base01}; @define-color color2 #${base02}; @define-color color3 #${base03};
          @define-color color4 #${base04}; @define-color color5 #${base05}; @define-color color6 #${base06}; @define-color color7 #${base07};
          @define-color color8 #${base08}; @define-color color9 #${base09}; @define-color color10 #${base10}; @define-color color11 #${base11};
          @define-color color12 #${base12}; @define-color color13 #${base13}; @define-color color14 #${base14}; @define-color color15 #${base15};
          * { font-size: 15px; font-family: "${font}"; }

          ${builtins.readFile ../../config/waybar/style.css}
        '';
    settings = [
      {
        layer = "top";
        position = "top";
        reload_style_on_change = true;

        modules-left = [
          "hyprland/submap"
          "group/name"
        ];
        modules-center = [
          "hyprland/workspaces"
        ];
        modules-right = [
          "custom/lyrics"
          "image#album-art"
          "cava"

          "cffi/cffi-blk"

          # "backlight/slider"
          # "pulseaudio/slider"

          # "hyprland/language"
          "group/expand"
          "network"
          "bluetooth"
          "battery"
          "clock"
        ];

        "cffi/cffi-blk" = {
          "module-path" = "cffi_blk/target/debug/libcffi_blk.so";
        };

        "pulseaudio/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
          device = "pulseaudio";
          scroll-step = 1;
        };

        "backlight/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
          device = "intel_backlight";
        };

        "image#album-art" = {
          exec = "~/dotnix/bin/album_art.sh";
          size = 24;
          interval = 5;
        };

        "custom/lyrics" = {
          format = " {}";
          interval = 2;
          exec = "lyrics-line.sh";
        };
        "custom/cava" = {
          format = "{}";
          exec = "cava.sh";
        };

        cava = {
          # cava_config = "~/dotnix/config/cava/shell";
          framerate = 60;
          autosens = 1;
          bars = 14;
          lower_cutoff_freq = 50;
          higher_cutoff_freq = 10000;
          method = "pulse";
          source = "auto";
          stereo = true;
          reverse = false;
          bar_delimiter = 0;
          monstercat = false;
          waves = false;
          noise_reduction = 0.77;
          input_delay = 2;
          format-icons = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
          actions = {
            on-click-right = "mode";
          };
        };

        "hyprland/workspaces" = {
          "format" = "{icon}";
          format-icons = {
            active = "";
            default = "";
            empty = "";
          };
          persistent-workspaces = {
            "*" = [1 2 3 4];
          };
        };
        "hyprland/language" = {
          format-en = "🦅";
          format-es = "🌮";
        };

        "custom/notification" = {
          tooltip = false;
          format = "";
          on-click = "swaync-client -t -sw";
          escape = true;
        };

        clock = {
          format = "{:%I:%M:%S%p}";
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
          tooltip-format-wifi = "{essid}({signalStrength}%)";
          tooltip-format-ethernet = "{ifname}🖧";
          on-click = "kittynmtui";
        };

        bluetooth = {
          format-on = "󰂯";
          format-off = "BT-off";
          format-disabled = "󰂲";
          format-connected-battery = "{device_battery_percentage}%󰂯";
          format-alt = "{device_alias}󰂯";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections}connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections}connected\n\n{device_enumerate}";
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
          format-plugged = "{capacity}% 󰂄";
          format-alt = "{time} {icon}";
          format-icons = ["󰁻" "󰁼" "󰁾" "󰂀" "󰂂" "󰁹"];
        };
        "custom/endpoint" = {
          format = "|";
          tooltip = false;
        };

        "custom/expand" = {
          format = "";
          tooltip = false;
        };

        "custom/name" = {
          format = ">";
          tooltip = false;
        };

        "group/name" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 600;
            transition-to-right = true;
            click-to-reveal = true;
          };
          modules = ["hyprland/window"];
        };

        "group/expand" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 600;
            transition-to-left = true;
            click-to-reveal = true;
          };
          modules = ["custom/expand" "tray" "cpu" "memory" "temperature" "custom/endpoint"];
        };

        cpu = {format = "󰻠{}";};

        memory = {format = "{}";};

        temperature = {
          critical-threshold = 80;
          format = "{}";
        };

        tray = {
          icon-size = 14;
          spacing = 10;
        };
      }

      #{
      #layer="top";
      #position="top";
      #mod="dock";
      #exclusive=true;
      #passtrough=false;
      #gtk-layer-shell=true;
      #height=0;
      #
      ##waybars-left=["hyprland/workspaces""hyprland/submap""wlr/taskbar"];
      ##waybars-right=["mpd""clock""temperature"];
      #modules-left=[
      #    "hyprland/workspaces"
      #    "custom/divider"
      #    "custom/weather"
      #    "custom/divider"
      #    "cpu"
      #    "custom/divider"
      #    "memory"
      #];
      #modules-center=["hyprland/window"];
      #modules-right=[
      #    "tray"
      #    "network"
      #    "custom/divider"
      #    "backlight"
      #    "custom/divider"
      #    "pulseaudio"
      #    "custom/divider"
      #    "battery"
      #    "custom/divider"
      #    "clock"
      #];
      #"hyprland/window"={format="{}";};
      #"wlr/workspaces"={
      #    on-scroll-up="hyprctldispatchworkspacee+1";
      #    on-scroll-down="hyprctldispatchworkspacee-1";
      #    all-outputs=true;
      #    on-click="activate";
      #};
      #battery={
      #    format="{capacity}%{icon}";
      #    format-icons=[""""""""""];
      #};
      #cpu={
      #    interval=10;
      #    format="󰻠{}%";
      #    max-length=10;
      #    on-click="";
      #};
      #memory={
      #    interval=30;
      #    format="{}%";
      #    format-alt="{used:0.1f}G";
      #    max-length=10;
      #};
      #backlight={
      #    format="󰖨{}";
      #    device="acpi_video0";
      #};
      #"custom/weather"={
      #    tooltip=true;
      #    format="{}";
      #    restart-interval=300;
      #    exec="/home/roastbeefer/.cargo/bin/weather";
      #};
      #tray={
      #    icon-size=13;
      #    tooltip=false;
      #    spacing=10;
      #};
      #network={
      #    format="󰖩{essid}";
      #    format-disconnected="󰖪disconnected";
      #};
      #clock={
      #    format="{:%I:%M%p%m/%d}";
      #    tooltip-format=''
      #    <big>{:%Y%B}</big>
      #    <tt><small>{calendar}</small></tt>'';
      #};
      #pulseaudio={
      #    format="{icon}{volume}%";
      #    tooltip=false;
      #    format-muted="Muted";
      #    on-click="pamixer-t";
      #    on-scroll-up="pamixer-i5";
      #    on-scroll-down="pamixer-d5";
      #    scroll-step=5;
      #    format-icons={
      #    headphone="";
      #    hands-free="";
      #    headset="";
      #    phone="";
      #    portable="";
      #    car="";
      #    default=[""""""];
      #    };
      #};
      #"pulseaudio#microphone"={
      #    format="{format_source}";
      #    tooltip=false;
      #    format-source="{volume}%";
      #    format-source-muted="Muted";
      #    on-click="pamixer--default-source-t";
      #    on-scroll-up="pamixer--default-source-i5";
      #    on-scroll-down="pamixer--default-source-d5";
      #    scroll-step=5;
      #};
      #"custom/divider"={
      #    format="|";
      #    interval="once";
      #    tooltip=false;
      #};
      #"custom/endright"={
      #    format="_";
      #    interval="once";
      #    tooltip=false;
      #};
      #}
    ];
  };
}
