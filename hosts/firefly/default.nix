# ASUS TUF, Intel with an RTX 2050; a server now, lid shut
{ inputs, ... }:

{
  imports = [
    ./hardware.nix
    ./services.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  dotnix = {
    user = "shawn";

    profiles = {
      base.enable = true;
      boot.enable = true;
      # the gpu and the second drive, for projects that need them
      compute.enable = true;
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

  # opens its secrets with its own ssh host key
  dotnix.secrets.hostKey = true;

  programs.libys.enable = false;

  # the second drive: music, backups, anything big. nofail, so a dead drive
  # costs the services on it, not the boot
  fileSystems."/srv" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  # the release this machine was installed with, not the current one
  system.stateVersion = "25.05";
}
