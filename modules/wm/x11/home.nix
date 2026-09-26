{ config, lib, ... }:

let
  inherit (lib.options) mkOption;
  inherit (lib) types;
  inherit (import ../types.nix { inherit lib; }) bind;
in

{
  imports = [ ../shared.nix ];

  options.dotnix.wm.x11 = {
    startup = mkOption {
      type = types.listOf types.str;
      description = "dotnix.wm.startup plus x11-only commands.";
    };

    binds = mkOption {
      type = types.listOf bind;
      description = "dotnix.wm.binds plus x11-only binds.";
    };
  };

  config.dotnix.wm.x11 = {
    inherit (config.dotnix.wm) startup binds;
  };
}
