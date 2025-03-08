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
            "xmodmap ~/.Xmodmap"
            "greenclip daemon"
            "xflux"
            "lastbg.sh"
            "alttab"
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

    # CapsLock to Control, and Shift+CapsLock to CapsLock:
    home.file.".Xmodmap".text = ''
      clear lock
      clear control
      add control = Caps_Lock Control_L Control_R
      keycode 66 = Control_L Caps_Lock NoSymbol NoSymbol
    '';
    home.packages = with pkgs; [
      xorg.xmodmap
      picom-pijulius
      xflux
      alttab
      feh
    ];
  };
}
