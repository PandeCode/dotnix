{
  lib,
  pkgs,
  sharedConfig,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/hosts/default.nix

    ../../modules/toolsets/gaming/os.nix

    ../../modules/wm/default.os.nix

    ../../modules/wm/sddm.nix
    ../../modules/wm/plymouth.nix

    ../../modules/hosts/stylix.nix

    ../../modules/hosts/sops.nix

    # ../../modules/hosts/virt_manager.nix
    # ../../modules/hosts/osx-kvm.nix
  ];

  virtualisation.waydroid.enable = false;
  zramSwap.enable = true;

  # hardware = {
  #   enable = true;
  #   graphics.extraPackages = [
  #     pkgs.intel-compute-runtime
  #   ];
  # };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      systemd-boot.enable = true;
      # systemd-boot.windows = {
      #   "11" = {
      #     title = "Windows 11";
      #     efiDeviceHandle = "/dev/nvme0n1p2";
      #   };
      # };
      # grub = {
      #   enable = true;
      #   useOSProber = true;
      #   device = "nodev";
      #   efiSupport = true;
      # };

      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
  };

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = rec {
    LC_TIME = "en_US.UTF-8";

    LC_ADDRESS = LC_TIME;
    LC_IDENTIFICATION = LC_TIME;
    LC_MEASUREMENT = LC_TIME;
    LC_MONETARY = LC_TIME;
    LC_NAME = LC_TIME;
    LC_NUMERIC = LC_TIME;
    LC_PAPER = LC_TIME;
    LC_TELEPHONE = LC_TIME;
  };

  users.users.${sharedConfig.user} = {
    isNormalUser = true;
    description = sharedConfig.user;
    extraGroups = ["networkmanager" "wheel" "video" "libvirtd" "input" "uinput" "docker"];
  };

  system.stateVersion = "24.11";
}
