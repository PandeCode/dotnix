# Framework 16, AMD Ryzen AI 300
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./services.nix
    inputs.nixos-hardware.nixosModules.framework-16-amd-ai-300-series
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # suspend-then-hibernate resumes from the swapfile below: systemd writes its
  # location to an efi variable on hibernate and the systemd initrd reads it
  boot.initrd.systemd.enable = true;

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
      laptop = {
        enable = true;
        power = "ppd";
      };
    };

    hardware.amd = {
      enable = true;
      rocm.enable = true;
    };
  };

  programs.coolercontrol.enable = true;

  # powertop's auto-tune lets the keyboard and the other input modules usb
  # autosuspend, and a key event lost around the wakeup leaves a key repeating.
  # ids from fwupd's framework-qmk quirk: ansi, macropad, numpad, iso, jis,
  # ansi copilot
  services.udev.extraRules = ''
    ACTION=="add|bind", SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0012|0013|0014|0018|0019|0030", TEST=="power/control", ATTR{power/control}="on"
  '';
  powerManagement.powertop.postStart = ''
    ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=32ac
  '';

  boot.supportedFilesystems = [
    "btrfs"
    "cifs"
    "f2fs"
    "ntfs"
    "vfat"
    "xfs"
  ];

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
