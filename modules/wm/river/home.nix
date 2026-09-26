# home-manager: rill, the window manager for river 0.4, and its
# config.zon. startup commands and command binds start from the shared wm
# declaration (dotnix.wm); everything else goes in `settings`.
# needs toZON (nixutils.lib.toZON): the flake exports this module with it
# applied
{ toZON }:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib) types;
  inherit (import ../types.nix { inherit lib; }) bind duplicateBinds;

  cfg = config.dotnix.river;

  modifier = {
    Super = "mod4";
    Alt = "mod1";
    Shift = "shift";
    Ctrl = "ctrl";
  };

  toKeybinding = b: {
    inherit (b) key;
    modifiers = lib.attrsets.genAttrs (map (
      m: modifier.${m} or (throw "river: unknown modifier ${m}")
    ) b.mods) (_: true);
    action.spawn = [
      "sh"
      "-c"
      b.exec
    ];
  };

  document = cfg.settings // {
    spawn_at_startup = map (cmd: [
      "sh"
      "-c"
      cmd
    ]) cfg.startup;
    keybindings = map toKeybinding cfg.binds ++ cfg.keybindings;
  };

  # zig fmt fails on anything that is not valid ZON
  configFile =
    pkgs.runCommandLocal "rill-config.zon"
      {
        nativeBuildInputs = [ pkgs.zig ];
        inherit (cfg) zon;
        passAsFile = [ "zon" ];
      }
      ''
        cp $zonPath config.zon
        ZIG_GLOBAL_CACHE_DIR=$TMPDIR zig fmt config.zon
        cp config.zon $out
      '';
in

{
  key = "dotnix#wm/river/home";

  imports = [ ../wayland/home.nix ];

  options.dotnix.river = {
    enable = mkEnableOption "rill in river";

    package = mkPackageOption pkgs "rill" { } // {
      description = "rill, from the nixbuilds overlay unless set.";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      example = {
        vertical_gap = 9;
        center_focused_window._enum = "always";
      };
      description = ''
        rill's config.zon as nix, converted with toZON. `{ _enum = "x"; }`
        writes the enum literal `.x`.
      '';
    };

    startup = mkOption {
      type = types.listOf types.str;
      description = "Shell commands at startup. Starts as dotnix.wm.wayland.startup.";
    };

    binds = mkOption {
      type = types.listOf bind;
      description = "Binds that run a command. Starts as dotnix.wm.wayland.binds.";
    };

    keybindings = mkOption {
      type = types.listOf (types.attrsOf types.anything);
      default = [ ];
      description = "rill keybindings with rill actions, after the command binds.";
    };

    zon = mkOption {
      type = types.str;
      readOnly = true;
      description = "The generated config.zon. For reading, not setting.";
    };
  };

  config = lib.modules.mkIf cfg.enable {
    assertions = [
      {
        assertion = duplicateBinds cfg.binds == [ ];
        message = "river: bound more than once: ${lib.strings.concatStringsSep ", " (duplicateBinds cfg.binds)}";
      }
    ];

    dotnix.river = {
      zon = toZON document;
      inherit (config.dotnix.wm.wayland) startup binds;
    };

    home.packages = [ cfg.package ];

    xdg.configFile = {
      "river/init" = {
        executable = true;
        text = ''
          #!/bin/sh
          exec ${lib.meta.getExe cfg.package}
        '';
      };

      "rill/config.zon".source = configFile;
    };
  };
}
