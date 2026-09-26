# option types shared by the wm modules
{ lib }:

let
  inherit (lib.options) mkOption;
  inherit (lib) types;
in

{
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
