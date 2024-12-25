{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  # options.hyprland.enable = mkOption {
  #   type = types.bool;
  #   default = false;
  #   description = "Enable the example service provided by hyprland.";
  # };
  #
  # config = mkIf config.hyprland.enable {
  home.packages = with pkgs; [
    hyprland
    xorg.xorgserver
  ];
  # };
}
