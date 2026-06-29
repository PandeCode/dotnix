# if you are crazy enough to run multiple factorio runs with different mods
# addtionally ~/.factorio/config/config.ini is a config file, its 2000 lines long :(
# making declarative mods is harder due to authentication being needed, maybe a plus since you can update mods from the game client, :(
_: let
  # h = config.home.homeDirectory;
  configs = [
    {
      name = "base";
      mod_folder = "~/.factorio/mods"; # vanilla
    }
    rec {
      name = "creative";
      comment = "creative/helmod/rate calculator etc";
      mod_folder = "~/.factorio/mods_${name}";
    }
    rec {
      name = "ultra_cube";
      mod_folder = "~/.factorio/mods_${name}";
      # icon = ""; # abs path or use "${config.home.homeDirectory}/Pictures/..." for something funny
      # https://wiki.archlinux.org/title/Desktop_entries#Icons
    }
    rec {
      name = "py";
      mod_folder = "~/.factorio/mods_${name}";
    }
    rec {
      name = "space_exploration";
      mod_folder = "~/.factorio/mods_${name}";
    }
  ];
in {
  # to do the same thing at the system level you have to manually write out the desktop entry and interpolate values
  xdg.desktopEntries =
    map (p: let
      comment =
        if p ? "comment"
        then p.comment
        else "The factory must grow";
      icon =
        if p ? "icon"
        then p.icon
        else "steam_icon_427520";
      args =
        # optional to show that you can repeat this for multiple options
        # more config can be spliced from ~.local/share/Steam/steamapps/common/Factorio/bin/x64/factorio -h
        if p ? "mod_folder"
        then "--mod-directory ${p.mod_folder}"
        else "";
    in {
      "factorio_${p.name}" = {
        name = "Factrio ${p.name}";
        inherit comment icon;

        exec =
          "steam steam://rungameid/427520 " # or directly run factorio
          + args;
        terminal = false;
        type = "Application";
        categories = ["Game" "Utility"];
      };
    })
    configs;

  # # if you want the directories to always exist
  # home.activation.setTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''mkdir -p ${builtins.concatStringSep " " (map (c: c.mod_folder) configs)} '';
  # # or
  # home.file = builtins.listToAttrs (map (c: {
  #     name = "${c.mod_folder}/.keep";
  #     value.text = "";
  #   })
  #   configs);
}
