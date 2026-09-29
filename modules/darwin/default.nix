{ config, inputs, ... }:

{
  imports = [
    ../generic
    inputs.home-manager.darwinModules.home-manager
  ];

  users.users.${config.dotnix.user}.home = "/Users/${config.dotnix.user}";
}
