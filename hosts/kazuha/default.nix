# Framework 16, AMD Ryzen AI 300
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.framework-16-amd-ai-300-series
    inputs.nix-index-database.nixosModules.default
  ];

  dotnix = {
    user = "shawn";
    niri.enable = true;
  };

  programs = {
    hermes = {
      enable = true;
      defaultEditor = true;
      nixd.nixos = ''(builtins.getFlake "${config.dotnix.flakePath}").nixosConfigurations.kazuha.options'';
    };

    libys.enable = true;

    nix-index-database.comma.enable = true;
  };

  boot = {
    tmp.cleanOnBoot = true;

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

  zramSwap.enable = true;
  systemd.oomd.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ];
  };

  time.timeZone = "America/Toronto";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = lib.attrsets.genAttrs [
      "LC_ADDRESS"
      "LC_IDENTIFICATION"
      "LC_MEASUREMENT"
      "LC_MONETARY"
      "LC_NAME"
      "LC_NUMERIC"
      "LC_PAPER"
      "LC_TELEPHONE"
      "LC_TIME"
    ] (_: "en_US.UTF-8");
  };

  # the release this machine was installed with, not the current one
  system.stateVersion = "25.05";
}
