# facts about the machine that the glue in hosts/ and modules/<class>
# reads. drop-in modules never read these
{ config, lib, ... }:

let
  inherit (lib.options) mkOption;
  inherit (lib) types;
in

{
  options.dotnix = {
    user = mkOption {
      type = types.str;
      description = "The main user of this machine.";
    };

    flakePath = mkOption {
      type = types.str;
      default = "${config.users.users.${config.dotnix.user}.home}/dotnix";
      defaultText = lib.literalExpression ''"<home of dotnix.user>/dotnix"'';
      description = "Where this repo is cloned, for configs linked outside the store.";
    };
  };
}
