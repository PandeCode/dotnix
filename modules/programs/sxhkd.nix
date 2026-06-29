{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.sxhkd;
in {
  options.sxhkd.enable = lib.mkEnableOption "enable sxhkd";

  config = lib.mkIf cfg.enable {
    services.sxhkd = {
      enable = true;
      extraConfig = '''';
      extraOptions = []; # cli ars
      keybindings = {
        "super + shift + {r,c}" = "i3-msg {restart,reload}";
        "super + {s,w}" = "i3-msg {stacking,tabbed}";
        "super + F1" = pkgs.writeShellScript "script" "echo $USER";
      };
    };
  };
}
