# every keys/*.pub may log in as dotnix.user, and nothing else can
{
  config,
  lib,
  self,
  ...
}:

let
  inherit (lib.attrsets) attrNames filterAttrs;
  inherit (lib.strings) hasSuffix;

  dir = "${self}/keys";

  keys =
    if builtins.pathExists dir then
      map (name: "${dir}/${name}") (
        attrNames (
          filterAttrs (name: type: type == "regular" && hasSuffix ".pub" name) (builtins.readDir dir)
        )
      )
    else
      [ ];
in

{
  options.dotnix.profiles.ssh.enable = lib.options.mkEnableOption "logging in over ssh, with a key";

  config = lib.modules.mkIf config.dotnix.profiles.ssh.enable {
    services.openssh = {
      enable = true;
      settings = {
        AllowUsers = [ config.dotnix.user ];
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    users.users.${config.dotnix.user}.openssh.authorizedKeys.keyFiles = keys;

    assertions = [
      {
        assertion = keys != [ ];
        message = "dotnix.profiles.ssh: no keys/*.pub, so nobody could log in.";
      }
    ];
  };
}
