{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.wayland;
in
  with lib; {
    imports = [
      ../home.nix
      ../../programs/waybar.nix
      ../../programs/swaync.nix
      # ../../programs/astal.nix
    ];

    options.wayland = {
      shared = mkOption {
        default = rec {
          inherit (config.wm.shared) terminal workspace_rules explorer;
          startup = [
            "swww-daemon"
            "wl-paste --type text --watch cliphist store" # Stores only text data
            "wl-paste --type image --watch cliphist store" # Stores only image data
          ];
          _bind = mod: key: exec: {inherit mod key exec;};
          mod = _bind "Super";
          nomod = _bind "";

          bindexec =
            config.wm.shared.bindexec
            ++ [
              (mod "n" "swaync-client -t -sw")
              (mod "z" "woomer")

              (_bind "Super Ctrl Shift" "c" "hyprpicker -a")

              (nomod "Print" "grimblast copy area")

              (_bind "Super Shift" "b" "toggle_waybar.sh")
              (_bind "Super Shift" "r" "wayrec.sh")

              (mod "v" "rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons")
              (_bind "Super Shift" "v" "bash -c \"cliphist list | rofi -dmenu | cliphist decode | xargs -I '{}' ydotool type '{}'\"")
            ];
          inherit (config.wm.shared) bindexec_el;
        };
      };
    };

    config = {
      services.hyprpolkitagent.enable = true;

      programs.hyprlock = {
        enable = true;
      };

      home.packages = with pkgs; [
        wlprop

        (import ../../../derivations/notify-send-py.nix {inherit lib pkgs;})
        hyprpicker
        hyprlock
        hyprsunset

        wayvnc # TODO: own file
      ];
    };
  }
