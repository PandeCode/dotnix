{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.wayland;
in
  with lib; {
    imports = [
      ../home.nix
      ../../programs/waybar.nix
    ];

    options.wayland = {
      wm.enable = true;

      enable = lib.mkEnableOption "enable wayland";

      shared = mkOption {
        default = rec {
          inherit (config.wm.shared) terminal;
          explorer = config.wm.shared.terminal;
          inherit (config.wm.shared) workspace_rules;
          startup = [
            "swww-daemon"
            "systemctl --user start hyprpolkitagent"
            "wl-paste --type text --watch cliphist store" # Stores only text data
            "wl-paste --type image --watch cliphist store" # Stores only image data
          ];
          _bind = mod: key: exec: {inherit mod key exec;};
          mod = _bind "super";
          nomod = _bind "";

          bindexec =
            config.wm.shared.bindexec
            ++ [
              (mod "z" "woomer")
              (mod "c" "hyprpicker -a")
              (mod "l" "hyprlock")

              (nomod "Print" "grimblast copy area")

              (mod "v" "rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons")
              (_bind "super shift" "v" "bash -c \"cliphist list | rofi -dmenu | cliphist decode | xargs -I '{}' ydotool type '{}'\"")
            ];
          inherit (config.wm.shared) bindexec_el;
        };
      };
    };

    config = lib.mkIf cfg.enable {
      rofi.enable = true;
      waybar.enable = true;

      services = {
        swaync = {
          enable = true;
          settings = {
          };
        };
      };

      home.packages = with pkgs; [
        hyprpicker
        hyprlock
        hyprsunset
      ];
    };
  }
