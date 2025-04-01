{
  pkgs,
  lib,
  config,
  ...
}: let
  _bind = mod: key: exec: {inherit mod key exec;};
  mod = _bind "super";
  nomod = _bind "";
in {
  imports = [
    ../home.nix
    ../../programs/sxhkd.nix
    ../../programs/greenclip.nix
    ../../programs/picom.nix
  ];

  options.x = {
    shared = lib.mkOption {
      default = {
        inherit (config.wm.shared) terminal workspace_rules explorer;
        startup =
          config.wm.shared.startup
          ++ [
             "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
            "xmodmap ~/.Xmodmap"
            "greenclip daemon"
            "xflux"
            "lastbg.sh"
            "alttab"
            "dunst"
            "picom -b --backend glx"
          ];
        bindexec =
          config.wm.shared.bindexec
          ++ [
            (nomod "Print" "")

            (mod "v" config.greenclip.commands.copy)
            (_bind "super shift" "v" config.greenclip.commands.copy)
          ];

        inherit (config.wm.shared) bindexec_el;
      };
    };
  };

  config = {
    greenclip.enable = true;
    picom.enable = true;

    home = {
      # CapsLock to Control, and Shift+CapsLock to CapsLock:
      file.".Xmodmap".text = ''
        clear lock
        clear control
        add control = Caps_Lock Control_L Control_R
        keycode 66 = Control_L Caps_Lock NoSymbol NoSymbol

        # Natural Scrolling
        # pointer = 1 2 3 5 4 7 6 8 9 10 11 12
      '';
      packages = with pkgs; [
        xorg.xmodmap
        picom-pijulius
        xflux
        alttab
        feh
        slop
        paperview
        xtitle
      ];
    };
  };
}
