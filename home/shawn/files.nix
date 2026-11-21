{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  yazi = config.programs.yazi;
  toml = pkgs.formats.toml { };

  open-with = pkgs.writeShellApplication {
    name = "open-with";
    runtimeInputs = [
      pkgs.gawk
      pkgs.glib
      pkgs.gtk3
    ];
    text = builtins.readFile ./scripts/open-with.sh;
  };

  # yazi's own config with the picker's keys and header on top, see
  # ../../config/yazi/picker.yazi
  pickerKeymap = lib.attrsets.recursiveUpdate yazi.keymap {
    mgr.prepend_keymap = [
      {
        on = "<Enter>";
        run = "plugin picker -- enter";
        desc = "Enter the folder, or pick the file";
      }
      {
        on = "s";
        run = "plugin picker -- here";
        desc = "Save here, or pick this folder";
      }
    ]
    ++ yazi.keymap.mgr.prepend_keymap;
  };

  pickerConfig = pkgs.linkFarm "yazi-picker-config" (
    map
      (name: {
        inherit name;
        path = config.xdg.configFile."yazi/${name}".source;
      })
      (
        lib.lists.filter (name: config.xdg.configFile ? "yazi/${name}") [
          "yazi.toml"
          "theme.toml"
        ]
      )
    ++ lib.attrsets.mapAttrsToList (name: plugin: {
      name = "plugins/${name}.yazi";
      path = plugin.package;
    }) yazi.plugins
    ++ [
      {
        name = "plugins/picker.yazi";
        path = ../../config/yazi/picker.yazi;
      }
      {
        name = "keymap.toml";
        path = toml.generate "yazi-picker-keymap" pickerKeymap;
      }
      {
        name = "init.lua";
        path = pkgs.concatText "yazi-picker-init" (
          lib.lists.optional (
            config.xdg.configFile ? "yazi/init.lua"
          ) config.xdg.configFile."yazi/init.lua".source
          ++ [ ../../config/yazi/picker.lua ]
        );
      }
    ]
  );

  yazi-picker = pkgs.writeShellApplication {
    name = "yazi-picker";
    runtimeInputs = [ yazi.finalPackage ];
    runtimeEnv.YAZI_CONFIG_HOME = pickerConfig;
    text = builtins.readFile ./scripts/yazi-picker.sh;
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

  # the portal runs this for every open and save dialog, in a ghostty of its
  # own that niri floats (yazi.picker in wm.nix)
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = lib.generators.toINI { } {
    filechooser = {
      cmd = lib.meta.getExe yazi-picker;
      default_dir = "$HOME";
      # no placeholder file in the folder, yazi asks for the name instead
      create_help_file = 0;
      open_mode = "suggested";
      save_mode = "suggested";
      env = "TERMCMD=${lib.meta.getExe config.programs.ghostty.package} --gtk-single-instance=false --quit-after-last-window-closed=true --class=yazi.picker";
    };
  };
}
