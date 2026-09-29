# ASUS TUF, Intel with an RTX 2050; a server now, lid shut
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
      base.enable = true;
      boot.enable = true;
      desktop = {
        enable = true;
        minimal = true;
      };
      # for the charge limit; the server profile keeps it awake
      laptop.enable = true;
      server.enable = true;
    };

    # the GPU sleeps until something computes on it
    hardware.nvidia = {
      enable = true;
      prime = {
        enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  programs.libys.enable = false;

  # the release this machine was installed with, not the current one
  system.stateVersion = "25.05";
}
