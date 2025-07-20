{
  pkgs,
  lib,
  config,
  ...
}: let
  _bind = mod: key: exec: {inherit mod key exec;};
  mod = _bind "super";
  mod_shift = _bind "super shift";
  mod_ctrl = _bind "super ctrl";
  nomod = _bind "";
in {
  imports = [
    ../home.nix
    ../../programs/sxhkd.nix
    ../../programs/greenclip.nix
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
            "picom -b"
          ];
        bindexec =
          config.wm.shared.bindexec
          ++ [
            (nomod "Print" "")

            (mod "v" config.greenclip.commands.copy)
            (_bind "super shift" "v" config.greenclip.commands.copy)

            (mod "d" "gromit-mpx --toggle && notify-send 'Gromit' 'Gromit-MPX toggled'")
            (mod_shift "d" "gromit-mpx --clear && notify-send 'Gromit' 'Screen cleared'")
            (mod_ctrl "d" "bash -c 'pgrep gromit-mpx && pkill gromit-mpx && notify-send 'Gromit' 'Gromit-MPX killed' || (gromit-mpx & notify-send 'Gromit' 'Gromit-MPX started')'")
          ];

        inherit (config.wm.shared) bindexec_el;
      };
    };
  };

  config = {
    services.gromit-mpx = {
      enable = true;
    };
    home = {
      # CapsLock to Control, and Shift+CapsLock to CapsLock:
      file.".Xmodmap".text = ''
        clear lock
        clear control
        add control = Caps_Lock Control_L Control_R
        keycode 66 = Control_L Caps_Lock NoSymbol NoSymbol
      '';
      packages = with pkgs; [
        slurp
        grim
        xclip
        xorg.xmodmap
        picom-pijulius
        xflux
        alttab
        feh
        scrot
        maim
        slop
        paperview
        xtitle
      ];
    };
  };
}
