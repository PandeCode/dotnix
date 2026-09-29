# ASUS TUF, Intel with an RTX 2050
{ inputs, ... }:

{
  imports = [
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  dotnix = {
    user = "shawn";

    profiles = {
      apps.enable = true;
      base.enable = true;
      boot.enable = true;
      desktop.enable = true;
      dev.enable = true;
      gaming = {
        enable = true;
        minecraft = true;
      };
      laptop.enable = true;
    };

    hardware.nvidia = {
      enable = true;
      prime = {
        enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      syncSpecialisation = true;
    };
  };

  services = {
    asusd.enable = true;
    supergfxd.enable = true;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # the release this machine was installed with, not the current one
  system.stateVersion = "25.05";
}
