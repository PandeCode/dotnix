# home-manager: the part of the shared declaration only wayland window
# managers use. starts from everything in dotnix.wm; add wayland-only
# commands on top
{ config, lib, ... }:

let
  inherit (lib.options) mkOption;
  inherit (lib) types;
  inherit (import ../types.nix { inherit lib; }) bind;
in

{
  imports = [ ../shared.nix ];

  options.dotnix.wm.wayland = {
    startup = mkOption {
      type = types.listOf types.str;
      description = "dotnix.wm.startup plus wayland-only commands.";
    };

    binds = mkOption {
      type = types.listOf bind;
      description = "dotnix.wm.binds plus wayland-only binds.";
    };
  };

  config.dotnix.wm.wayland = {
    inherit (config.dotnix.wm) startup binds;
  };
}
