# modes: other versions of your home, built with it and switched to without
# a rebuild. `mode` lists them, `mode <name>` turns one on, `mode off` goes
# back. a rebuild always lands on the usual home
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkOption;
  inherit (lib) types;

  cfg = config.dotnix.modes;

  hooks = pkgs.linkFarm "mode-hooks" (
    lib.attrsets.concatMapAttrs (name: mode: {
      "${name}/on" = pkgs.writeShellScript "mode-${name}-on" mode.on;
      "${name}/off" = pkgs.writeShellScript "mode-${name}-off" mode.off;
    }) cfg
  );

  mode = pkgs.writeShellApplication {
    name = "mode";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      state=''${XDG_STATE_HOME:-$HOME/.local/state}
      dir=$state/dotnix
      mkdir -p "$dir"

      current=$(readlink -e "$state/home-manager/gcroots/current-home")
      active=$(cat "$dir/mode" 2>/dev/null || echo off)

      # only the usual home has the modes in it
      if [[ -d $current/specialisation ]]; then
        echo "$current" >"$dir/home"
        # a rebuild switched back on its own; finish turning it off
        if [[ $active != off ]]; then
          "${hooks}/$active/off" || true
          rm "$dir/mode"
          active=off
        fi
      fi
      home=$(cat "$dir/home")

      target=''${1:-}
      if [[ -z $target ]]; then
        for name in off $(ls "$home/specialisation"); do
          if [[ $name == "$active" ]]; then echo "* $name"; else echo "  $name"; fi
        done
        exit 0
      fi

      if [[ $target != off && ! -e $home/specialisation/$target ]]; then
        echo "mode: no mode called $target" >&2
        exit 2
      fi
      [[ $target == "$active" ]] && exit 0

      [[ $active != off ]] && "${hooks}/$active/off"
      if [[ $target == off ]]; then
        "$home/activate" --driver-version 1
        rm -f "$dir/mode"
      else
        "$home/specialisation/$target/activate" --driver-version 1
        echo "$target" >"$dir/mode"
        "${hooks}/$target/on"
      fi
    '';
  };
in

{
  options.dotnix.modes = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          config = mkOption {
            type = types.deferredModule;
            default = { };
            description = "Home config on top of the usual one while the mode is on.";
          };

          on = mkOption {
            type = types.lines;
            default = "";
            description = "Run after the mode turns on, for what config can't change.";
          };

          off = mkOption {
            type = types.lines;
            default = "";
            description = "Run when the mode turns off, to undo `on`.";
          };
        };
      }
    );
    default = { };
    description = "Named modes, switched with `mode <name>` and `mode off`.";
  };

  config = lib.modules.mkIf (cfg != { }) {
    specialisation = lib.attrsets.mapAttrs (_: mode: { configuration = mode.config; }) cfg;
    home.packages = [ mode ];
  };
}
