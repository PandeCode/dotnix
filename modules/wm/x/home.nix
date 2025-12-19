{
  pkgs,
  lib,
  config,
  inputs,
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
        bindexec = let
          mkscale = v: "sh -c 'xrandr --output $(xrandr | grep connected | grep -v disconnected | awk \\'{print $1}\\') --scale ${v}'";
        in
          config.wm.shared.bindexec
          ++ [
            (nomod "Print" "maim -s | xclip -selection clipboard -t image/png")

            (mod "d" "dunstctl context")
            (mod_shift "d" "dunstctl close-all")

            (mod "v" config.greenclip.commands.copy)
            (mod_shift "v" config.greenclip.commands.paste)

            (mod_ctrl "v" config.greenclip.commands.restart)

            (mod_shift "-" (mkscale "0.8x0.8"))
            (mod_shift "+" (mkscale "1.2x1.2"))

            # (mod "d" "gromit-mpx --toggle && notify-send 'Gromit' 'Gromit-MPX toggled'")
            # (mod_shift "d" "gromit-mpx --clear && notify-send 'Gromit' 'Screen cleared'")
            # (mod_ctrl "d" "bash -c 'pgrep gromit-mpx && pkill gromit-mpx && notify-send 'Gromit' 'Gromit-MPX killed' || (gromit-mpx & notify-send 'Gromit' 'Gromit-MPX started')'")
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
      # gromit-mpx = { enable = false; };
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
        xdo
        libxcvt
        slurp
        grim
        xclip
        xorg.xmodmap
        picom-pijulius
        # alttab
        feh
        scrot
        maim
        slop
        paperview
        xtitle
        xmenu

        xwinwrap

        inputs.boomer.packages.${pkgs.system}.default

        dmenu
        # dmenu-rs-enable-plugins
      ];
    };
  };
}
