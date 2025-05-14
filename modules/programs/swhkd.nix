{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.swhkd;
in {
  imports = [
    # ../wm/dwm/home.nix
    # ../wm/i3/home.nix
    # ../wm/sway/home.nix
    # ../wm/hyprland/home.nix
    # ../wm/xmonad/home.nix
    # ../wm/bspwm/home.nix
  ];

  options.swhkd.enable = lib.mkEnableOption "enable swhkd";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [swhkd];
    xdg.configFile = rec {
      "swhkd/tty.sxhkd".text = ''
        XF86Audio{Prev,Next}
        	mpc -q {prev,next}
      '';

      "swhkd/wm.sxhkd".text = '''';

      "swhkd/x.sxhkd".text = '''';
      "swhkd/wayland.sxhkd".text = '''';

      # ${${"swhkd/wm.sxhkd"}.text}
      # ${${"swhkd/x.sxhkd"|}.text}
      "swhkd/dwm.sxhkd".text = ''


      '';
      "swhkd/hyprland.sxhkd".text = '''';
      "swhkd/i3.sxhkd".text = ''
        super + {h,j,k,l}
        	i3-msg focus {left,down,up,right}
      '';
      "swhkd/sway.sxhkd".text = '''';
      "swhkd/xmonad.sxhkd".text = '''';
    };
  };
}
