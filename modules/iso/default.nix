# a live system that is also an installer
{
  config,
  modulesPath,
  pkgs,
  self,
  ...
}:

{
  imports = [
    ../nixos
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    "${modulesPath}/installer/cd-dvd/latest-kernel.nix"
  ];

  # the running system links its dotfiles from here, and the installer
  # copies it to the new machine
  dotnix.flakePath = "/etc/dotnix";
  environment = {
    etc.dotnix.source = self;
    systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.dotnix-install ];
  };

  users.users.${config.dotnix.user}.initialHashedPassword = "";

  services.displayManager.autoLogin = {
    enable = true;
    inherit (config.dotnix) user;
  };
}
