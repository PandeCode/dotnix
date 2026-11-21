{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  open-with = pkgs.writeShellApplication {
    name = "open-with";
    runtimeInputs = [
      pkgs.gawk
      pkgs.glib
      pkgs.gtk3
    ];
    text = builtins.readFile ./scripts/open-with.sh;
  };
in

lib.modules.mkIf osConfig.dotnix.profiles.desktop.enable {
  programs.yazi = {
    enable = true;
    # y in the shell, and the shell follows yazi's last folder
    shellWrapperName = "y";

    extraPackages = [
      open-with
      pkgs.dragon-drop
      pkgs.udisks
      pkgs.util-linux
    ];

    plugins.mount = pkgs.yaziPlugins.mount;

    settings.mgr = {
      sort_by = "natural";
      linemode = "size";
    };

    keymap.mgr.prepend_keymap = [
      {
        on = "M";
        run = "plugin mount";
        desc = "Mount, unmount and eject drives";
      }
      {
        on = "<C-o>";
        run = "shell --orphan -- open-with %s";
        desc = "Open with an app picked from rofi";
      }
      {
        on = "<C-n>";
        run = "shell --orphan -- dragon-drop --and-exit --all --on-top %s";
        desc = "Drag the selected files out";
      }
      {
        on = "<C-t>";
        run = "shell --orphan -- dragon-drop --target --and-exit --print-path | xargs -r -d '\\n' cp -rt .";
        desc = "Drop files in here, as copies";
      }
    ];
  };
}
