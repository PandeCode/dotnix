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
            "dunst"
            "bg.sh last"
            "alttab"
            "picom -b"
          ];
        bindexec =
          config.wm.shared.bindexec
          ++ [
            (nomod "Print" "maim -s | xclip -selection clipboard -t image/png")

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
    services = {
      dunst = {
        enable = true;
        settings = {
          global = {
            dmenu = "dmenu -p dunst:";
            browser = "xdg-open";
          };
        };
      };
      gromit-mpx = {
        enable = true;
      };
    };
    dotnix = {
      enable = true;
      symlinkPairs = [
        ["${config.home.homeDirectory}/dotnix/config/picom/picom.conf" "${config.home.homeDirectory}/.config/picom/picom.conf"]
      ];
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
        libxcvt
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
        xmenu

        (dmenu-rs-enable-plugins.override {enablePlugins = true;})
      ];
    };
  };
}
