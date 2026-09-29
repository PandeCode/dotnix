{ lib }:

let
  inherit (lib.options) mkOption;
  inherit (lib) types;
in

{
  duplicateBinds =
    binds:
    let
      combo =
        b: lib.strings.concatStringsSep "+" (lib.lists.sort lib.trivial.lessThan b.mods ++ [ b.key ]);
      combos = map combo binds;
    in
    lib.lists.unique (lib.lists.filter (c: lib.lists.count (x: x == c) combos > 1) combos);

  bind = types.submodule {
    options = {
      mods = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [
          "Super"
          "Shift"
        ];
      };
      key = mkOption {
        type = types.str;
        example = "Return";
      };
      exec = mkOption {
        type = types.str;
        description = "Shell command to run.";
      };
      locked = mkOption {
        type = types.bool;
        default = false;
        description = "Also works while the screen is locked (media and brightness keys).";
      };
    };
  };
}
