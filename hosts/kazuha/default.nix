# Framework 16, AMD Ryzen AI 300
{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.framework-16-amd-ai-300-series
  ];

  dotnix = {
    user = "shawn";

    profiles = {
      apps.enable = true;
      base.enable = true;
      desktop.enable = true;
      dev.enable = true;
      gaming = {
        enable = true;
        minecraft = true;
      };
      laptop.enable = true;
    };

    hardware.amd = {
      enable = true;
      rocm.enable = true;
    };
  };

  programs.coolercontrol.enable = true;

  boot = {
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        theme = pkgs.hyperfluent-grub-theme;
      };
    };

    supportedFilesystems = lib.modules.mkForce [
      "btrfs"
      "cifs"
      "f2fs"
      "ntfs"
      "reiserfs"
      "vfat"
      "xfs"
    ];
  };

  virtualisation.waydroid.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # the laptop screen, for screen sharing under river
  xdg.portal.wlr.settings.screencast.output_name = "eDP-1";

  # the release this machine was installed with, not the current one
  system.stateVersion = "25.05";
}
