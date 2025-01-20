{
  lib,
  config,
  ...
}: let
  cfg = config.waybar;
in {
  options.waybar.enable = lib.mkEnableOption "enable waybar";

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          height = 30;
          output = ["DP-1"];
          waybars-left = ["hyprland/workspaces" "hyprland/submap" "wlr/taskbar"];
          waybars-center = ["hyprland/window"];
          waybars-right = ["mpd" "clock" "temperature"];
          battery = {
            format = "{capacity}% {icon}";
            format-icons = ["" "" "" "" ""];
          };
          clock = {
            format-alt = "{:%a, %d. %b  %H:%M}";
          };
        }
        {
          layer = "top";
          position = "top";
          output = "!DP-1";
          waybars-right = ["clock"];
        }
      ];
    };
  };
}
