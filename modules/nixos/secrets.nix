# sops-nix: secrets stay encrypted in git and the store and are opened at boot
# into /run/secrets. which secrets, and from which file, is for each config
# to say through sops.secrets and sops.defaultSopsFile
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.modules) mkDefault mkIf;

  cfg = config.dotnix.secrets;
in

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  # the age key never has to be copied onto the machine; its recipient for
  # .sops.yaml: `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`
  options.dotnix.secrets.hostKey = lib.options.mkEnableOption "opening secrets with this machine's ssh host key instead of the user's age key";

  config = {
    sops = {
      defaultSopsFormat = "yaml";
      age =
        if cfg.hostKey then
          { sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; }
        else
          { keyFile = mkDefault "/home/${config.dotnix.user}/.config/sops/age/keys.txt"; };
    };

    environment.systemPackages = mkIf (config.sops.secrets != { }) [ pkgs.sops ];
  };
}
