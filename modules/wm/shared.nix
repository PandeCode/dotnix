{ lib, ... }:

let
  inherit (lib.options) mkOption;
  inherit (lib) types;

  inherit (import ./types.nix { inherit lib; }) bind;

  rule = mkOption {
    type = types.listOf types.str;
    default = [ ];
    description = ''Window classes or app ids; "title:<text>" matches a title instead.'';
  };
in

{
  options.dotnix.wm = {
    terminal = mkOption {
      type = types.str;
      default = "xterm";
    };

    shell = mkOption {
      type = types.str;
      default = "bash";
    };

    explorer = mkOption {
      type = types.str;
      default = "xdg-open .";
    };

    startup = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Shell commands run when any window manager starts.";
    };

    binds = mkOption {
      type = types.listOf bind;
      default = [ ];
      description = "Key bindings that run a command, in every window manager.";
    };

    rules = {
      float = rule;
      pin = rule;
      noblur = rule;
      noshadow = rule;
      noborder = rule;

      workspaces = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = { };
        example = {
          "1" = [ "alacritty" ];
        };
        description = "Workspace name to the windows that open on it.";
      };
    };
  };
}
