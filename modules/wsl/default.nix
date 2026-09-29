{ config, inputs, ... }:

{
  imports = [
    ../nixos
    (inputs.nixos-wsl or (throw "wsl hosts need the NixOS-WSL input, named nixos-wsl"))
    .nixosModules.default
  ];

  wsl = {
    enable = true;
    defaultUser = config.dotnix.user;
  };
}
