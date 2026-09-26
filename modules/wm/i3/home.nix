# home-manager: i3, from the shared wm declaration (dotnix.wm). fills
# home-manager's own xsession.windowManager.i3 options: command binds,
# startup, terminal, floating/sticky/borderless windows, and optionally
# workspace assignments. everything else is set there directly
{ config, lib, ... }:

let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  inherit (import ../types.nix { inherit lib; }) bind duplicateBinds;

  cfg = config.dotnix.i3;
  inherit (config.dotnix.wm) rules;

  modifier = {
    Super = "Mod4";
    Alt = "Mod1";
    Shift = "Shift";
    Ctrl = "Ctrl";
  };

  toKeybinding = b: {
    name = lib.strings.concatStringsSep "+" (
      map (m: modifier.${m} or (throw "i3: unknown modifier ${m}")) b.mods ++ [ b.key ]
    );
    value = "exec --no-startup-id ${b.exec}";
  };

  # "title:<text>" matches the title, anything else the class
  toCriteria =
    entry:
    if lib.strings.hasPrefix "title:" entry then
      { title = lib.strings.removePrefix "title:" entry; }
    else
      { class = entry; };

  commandFor =
    command: entries:
    map (entry: {
      inherit command;
      criteria = toCriteria entry;
    }) entries;
in

{
  imports = [ ../x11/home.nix ];

  options.dotnix.i3 = {
    enable = mkEnableOption "i3 from the shared wm declaration";

    startup = mkOption {
      type = types.listOf types.str;
      description = "Shell commands at startup. Starts as dotnix.wm.x11.startup.";
    };

    binds = mkOption {
      type = types.listOf bind;
      description = "Binds that run a command. Starts as dotnix.wm.x11.binds.";
    };

    assignWorkspaces = mkEnableOption "moving windows to the workspaces in dotnix.wm.rules.workspaces";
  };

  config = lib.modules.mkIf cfg.enable {
    dotnix.i3 = {
      inherit (config.dotnix.wm.x11) startup binds;
    };

    assertions = [
      {
        assertion = duplicateBinds cfg.binds == [ ];
        message = "i3: bound more than once: ${lib.strings.concatStringsSep ", " (duplicateBinds cfg.binds)}";
      }
    ];

    xsession.windowManager.i3 = {
      enable = true;

      config = {
        inherit (config.dotnix.wm) terminal;

        keybindings = lib.attrsets.listToAttrs (map toKeybinding cfg.binds);

        startup = map (command: {
          inherit command;
          notification = false;
        }) cfg.startup;

        floating.criteria = map toCriteria rules.float;

        window.commands = commandFor "sticky enable" rules.pin ++ commandFor "border none" rules.noborder;

        assigns = lib.modules.mkIf cfg.assignWorkspaces (
          lib.attrsets.mapAttrs (_: map toCriteria) rules.workspaces
        );
      };
    };
  };
}
