{
  sharedConfig,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "/home/${sharedConfig.user}/.config/sops/age/keys.txt";

    secrets = {
    };
  };
}
