# home-manager: niri's config.kdl, generated from nix. startup commands,
# command binds and floating windows start from the shared wm declaration
# (dotnix.wm); everything else goes in `settings`
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.strings)
    concatMapStrings
    concatStringsSep
    hasPrefix
    removePrefix
    ;
  inherit (lib) types;
  inherit (import ../types.nix { inherit lib; }) bind;

  cfg = config.dotnix.niri;

  toBind = b: {
    name = concatStringsSep "+" (b.mods ++ [ b.key ]);
    value = {
      spawn-sh = b.exec;
    }
    // lib.attrsets.optionalAttrs b.locked { _props.allow-when-locked = true; };
  };

  # "title:<text>" matches the title, anything else the app id
  toMatch =
    entry:
    if hasPrefix "title:" entry then { title = removePrefix "title:" entry; } else { app-id = entry; };

  # nodes that repeat (spawn-sh-at-startup, window-rule, ...) must be
  # ordered children for toKDL
  document = cfg.settings // {
    _children =
      map (cmd: { spawn-sh-at-startup = cmd; }) cfg.startup
      ++ lib.lists.optional (cfg.floating != [ ]) {
        window-rule = {
          _children = map (entry: { match._props = toMatch entry; }) cfg.floating;
          open-floating = true;
        };
      }
      ++ map (rule: { window-rule = rule; }) cfg.windowRules
      ++ map (rule: { layer-rule = rule; }) cfg.layerRules;
  };

  generated = pkgs.writeText "niri-generated.kdl" cfg.kdl;

  # validated before the includes are added: those are live files that do
  # not exist at build time
  configFile = pkgs.runCommand "niri-config.kdl" { nativeBuildInputs = [ cfg.package ]; } ''
    niri validate -c ${generated}
    cat ${generated} > $out
    ${concatMapStrings (file: "echo 'include \"${file}\"' >> $out\n") cfg.includes}
  '';

  shaders = lib.attrsets.mapAttrs' (name: file: {
    name = "window-${name}";
    value.custom-shader = builtins.readFile file;
  }) (lib.attrsets.filterAttrs (_: file: file != null) cfg.shaders);
in

{
  imports = [ ../wayland/home.nix ];

  options.dotnix.niri = {
    enable = mkEnableOption "niri's config";

    package = mkPackageOption pkgs "niri" { } // {
      description = "Used to validate the config at build time.";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      example = {
        prefer-no-csd = { };
        input.touchpad.tap = { };
        binds."Super+h".focus-column-left = { };
      };
      description = ''
        config.kdl as nix, in home-manager's toKDL shape: a node is an
        attribute, `{ }` is a node without arguments, `_args` and `_props`
        hold arguments and properties.
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

    floating = mkOption {
      type = types.listOf types.str;
      description = "Windows that open floating. Starts as dotnix.wm.rules.float.";
    };

    windowRules = mkOption {
      type = types.listOf (types.attrsOf types.anything);
      default = [ ];
      description = "window-rule nodes, in order.";
    };

    layerRules = mkOption {
      type = types.listOf (types.attrsOf types.anything);
      default = [ ];
      description = "layer-rule nodes, in order.";
    };

    shaders = lib.attrsets.genAttrs [ "open" "close" "resize" ] (
      name:
      mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "GLSL file for the window-${name} animation.";
      }
    );

    kdl = mkOption {
      type = types.str;
      readOnly = true;
      description = "The generated config, without includes. For reading, not setting.";
    };

    includes = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "~/dotnix/config/niri/live.kdl" ];
      description = ''
        Files included at the end of config.kdl. They override the
        generated config and niri reloads them on change, so they are good
        for trying things without a switch.
      '';
    };
  };

  config = lib.modules.mkIf cfg.enable {
    dotnix.niri = {
      kdl = lib.hm.generators.toKDL { escapeBackslashes = true; } document;

      inherit (config.dotnix.wm.wayland) startup binds;
      floating = config.dotnix.wm.rules.float;

      settings = lib.modules.mkMerge [
        { binds = lib.attrsets.listToAttrs (map toBind cfg.binds); }
        (lib.modules.mkIf (shaders != { }) { animations = shaders; })
      ];
    };

    xdg.configFile."niri/config.kdl".source = configFile;
  };
}
